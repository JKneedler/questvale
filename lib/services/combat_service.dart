import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/data/providers/game_data_models/enemy_attack_data.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:questvale/data/repositories/scheduled_timer_repository.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/services/class_resource_resolver.dart';
import 'package:questvale/services/mote_service.dart';
import 'package:questvale/services/status_effect_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DamageData {
  final double damageMultiplier;
  final SkillDamageType damageType;

  DamageData({required this.damageMultiplier, required this.damageType});
}

class DamageResult {
  final int damageDone;
  final bool didKill;

  DamageResult({required this.damageDone, required this.didKill});
}

// Bundles resolveDamageAgainstEnemy's two outputs — the DamageResult a
// caller reports, and the Enemy row a caller still needs to persist. No
// records in this SDK version (<3.0.0), hence a plain class rather than a
// `(Enemy, DamageResult)` tuple.
class DamageResolution {
  final Enemy updatedEnemy;
  final DamageResult result;

  const DamageResolution({required this.updatedEnemy, required this.result});
}

// Why a skill cast did or didn't happen — CombatCubit reads this to decide
// whether to reload combat state or surface a blocked-cast reason. Real UI
// for the blocked reasons is its own pass (see the Skill System Foundations
// ticket) — for now a block just means "nothing happened."
enum SkillCastBlockReason { insufficientAp, onCooldown }

class SkillCastResult {
  final bool wasCast;
  final SkillCastBlockReason? blockReason;

  const SkillCastResult._({required this.wasCast, this.blockReason});

  static const success = SkillCastResult._(wasCast: true);
  static const insufficientAp = SkillCastResult._(
      wasCast: false, blockReason: SkillCastBlockReason.insufficientAp);
  static const onCooldown = SkillCastResult._(
      wasCast: false, blockReason: SkillCastBlockReason.onCooldown);
}

// Everything CombatService.castSkill resolved before handing control to the
// skill's own execute() — AP/cooldown were already checked and applied by
// the time this exists, so a skill never sees a context for a cast that
// didn't happen. Replaces the old bespoke MoteInteractionResult parameter on
// BaseActiveSkill.execute() with one bundle that generalizes to any future
// class resource, per the vault's Skill System Architecture note.
class SkillCastContext {
  final Character caster;
  final SkillData skillData;
  final ClassResourceResult resourceResult;
  // Null when the skill has no cooldown (e.g. Arcane Bolt) — no timer is
  // armed for a 0-cooldown skill, since there's nothing to wait out.
  final ScheduledTimer? cooldownTimer;
  // The encounter this cast happened in — skills that apply a status
  // effect (Firebolt's Burn, Frost Shard's Slow) need this to scope the
  // ScheduledTimer they arm, same as cooldownTimer above.
  final String encounterId;

  const SkillCastContext({
    required this.caster,
    required this.skillData,
    required this.resourceResult,
    required this.encounterId,
    this.cooldownTimer,
  });

  // Convenience passthrough so Mage skills can keep reading
  // `context.moteResult` exactly like they read the old `moteResult`
  // parameter, without every skill needing to know about the
  // ClassResourceResolver indirection behind it. Resolves to
  // MoteInteractionResult.none for any non-Mage cast, same default as
  // before.
  MoteInteractionResult get moteResult {
    final result = resourceResult;
    return result is MoteClassResourceResult
        ? result.moteResult
        : MoteInteractionResult.none;
  }
}

class CombatService {
  final Database db;
  late CharacterRepository characterRepository;
  late EnemyRepository enemyRepository;
  late ScheduledTimerRepository scheduledTimerRepository;
  late StatusEffectService statusEffectService;

  CombatService({required this.db}) {
    characterRepository = CharacterRepository(db: db);
    enemyRepository = EnemyRepository(db: db);
    scheduledTimerRepository = ScheduledTimerRepository(db: db);
    statusEffectService = StatusEffectService(db: db);
  }

  // The single orchestration point for a skill cast (see the vault's Skill
  // System Architecture note) — checks/spends AP, checks/arms the skill's
  // cooldown, resolves the caster's class resource, then hands the skill's
  // own execute() one SkillCastContext bundling all of that. Nothing before
  // this ticket enforced AP or cooldowns at all; every skill was castable
  // for free, unlimited times, back-to-back.
  Future<SkillCastResult> castSkill({
    required BaseActiveSkill skill,
    required Character character,
    required PlayerCombatStats playerCombatStats,
    required List<Enemy> targets,
    required String encounterId,
  }) async {
    final skillData = skill.data;
    final apCost = skillData.apCost ?? 0;
    if (character.actionPoints < apCost) {
      return SkillCastResult.insufficientAp;
    }

    final ownerId = cooldownOwnerId(character.id, skillData.id);
    final now = DateTime.now();
    final existingCooldown = await scheduledTimerRepository.getTimerForOwner(
        ownerId, ScheduledTimerKind.skillCooldown);
    if (!isSkillReady(existingCooldown, now)) {
      return SkillCastResult.onCooldown;
    }

    final updatedCharacter = await characterRepository.updateCharacter(
        character.copyWith(actionPoints: character.actionPoints - apCost));

    final resolver = ClassResourceResolver.forCharacterClass(
        character.characterClass, characterRepository);
    final resourceResult = await resolver.resolve(skillData, character.id);

    ScheduledTimer? cooldownTimer;
    if ((skillData.cooldown ?? 0) > 0) {
      final timer = buildCooldownTimer(
        character: character,
        skillData: skillData,
        encounterId: encounterId,
        now: now,
        id: existingCooldown?.id ?? const Uuid().v4(),
      );
      if (existingCooldown != null) {
        await scheduledTimerRepository.updateTimer(timer);
      } else {
        await scheduledTimerRepository.insertTimer(timer);
      }
      cooldownTimer = timer;
    }

    final context = SkillCastContext(
      caster: updatedCharacter,
      skillData: skillData,
      resourceResult: resourceResult,
      encounterId: encounterId,
      cooldownTimer: cooldownTimer,
    );

    await skill.execute(this, playerCombatStats, targets, context);

    return SkillCastResult.success;
  }

  // A composite owner id so one character's several skills each get their
  // own cooldown row under ScheduledTimerRepository's existing
  // one-timer-per-(ownerId, kind) shape, without a schema change.
  static String cooldownOwnerId(String characterId, String skillId) =>
      '$characterId:$skillId';

  // Pure — no DB, unit testable on its own (see combat_service_test.dart).
  static ScheduledTimer buildCooldownTimer({
    required Character character,
    required SkillData skillData,
    required String encounterId,
    required DateTime now,
    required String id,
  }) {
    final cooldownMs =
        ((skillData.cooldown ?? 0) * Duration.millisecondsPerHour).round();
    return ScheduledTimer(
      id: id,
      ownerId: cooldownOwnerId(character.id, skillData.id),
      encounterId: encounterId,
      kind: ScheduledTimerKind.skillCooldown,
      payload: skillData.id,
      remainingWorkMs: cooldownMs,
      segmentStartedAt: now,
      currentRate: 1.0,
      nextTriggerAt: now.add(Duration(milliseconds: cooldownMs)),
      recurring: false,
    );
  }

  // A skill with no cooldown timer at all (nothing was ever armed, or
  // nothing exists yet for it) is always ready. Pure — no DB.
  static bool isSkillReady(ScheduledTimer? cooldownTimer, DateTime now) {
    if (cooldownTimer == null) return true;
    return !cooldownTimer.nextTriggerAt.isAfter(now);
  }

  // The damage-application seam (see the Skill System Foundations ticket,
  // subtask 2). Base attack power — selected by the skill's declared
  // SkillDamageType via PlayerCombatStats.attackPowerFor — is the one stat
  // wired live here. Every other StatModifierType has an equally obvious
  // slot to be added at, right where this multiplies damageMultiplier by
  // attackPower, but none of them are consulted yet:
  //   - crit: roll playerCombatStats.critChance; on a hit, multiply by
  //     playerCombatStats.critDamage
  //   - armor: mitigate against the enemy's armor stat (no such field
  //     exists on Enemy yet either)
  //   - elemental resistance/weakness/immunity: consult the enemy's
  //     immunities/resistances/weaknesses against damageData.damageType
  //   - Mote Potency: scale a mote-consumer skill's damage by
  //     playerCombatStats.motePotency (deferred to its own pass —
  //     Ember Burst/Hoarfrost Burst stay unaffected by gear this pass)
  // damageReflection/lifeSteal/blockChance apply to the player-facing side
  // of combat (enemy attacks, healing), not here.
  //
  // Pure — no DB — so it's unit testable on its own (see
  // combat_service_test.dart). A fresh/ungeared character has 0 base
  // attack power and so deals 0 damage until they roll attackPower on
  // gear — an intentional consequence of wiring the real formula, not a
  // bug; no artificial floor is added, since that would be balance
  // tuning this ticket deliberately leaves out.
  static int computeRawDamage(
      DamageData damageData, PlayerCombatStats playerCombatStats) {
    final attackPower = playerCombatStats.attackPowerFor(damageData.damageType);
    return (damageData.damageMultiplier * attackPower).round();
  }

  // The clamp-against-current-HP/did-this-kill-it math, factored out as a
  // pure function so StatusEffectService's Burn tick resolution can share
  // it without needing a full CombatService instance — CombatService
  // itself owns a StatusEffectService (see the constructor above), so
  // StatusEffectService holding a CombatService back would be a circular
  // instantiation. Unit testable on its own (see combat_service_test.dart).
  static DamageResolution resolveDamageAgainstEnemy(int damage, Enemy enemy) {
    int damageDone = 0;
    bool didKill = false;
    if (enemy.currentHealth < damage) {
      damageDone = enemy.currentHealth;
      didKill = true;
    } else {
      damageDone = damage;
    }
    final newHealth = enemy.currentHealth - damageDone;
    if (newHealth <= 0) didKill = true;
    return DamageResolution(
      updatedEnemy: enemy.copyWith(currentHealth: newHealth),
      result: DamageResult(damageDone: damageDone, didKill: didKill),
    );
  }

  Future<DamageResult> applyDamage(DamageData damageData,
      PlayerCombatStats playerCombatStats, String enemyId) async {
    final damage = computeRawDamage(damageData, playerCombatStats);
    return _applyDamageAmount(damage, enemyId);
  }

  Future<DamageResult> _applyDamageAmount(int damage, String enemyId) async {
    final enemy = await enemyRepository.getEnemyById(enemyId);
    final resolved = resolveDamageAgainstEnemy(damage, enemy);
    await enemyRepository.updateEnemy(resolved.updatedEnemy);
    return resolved.result;
  }

  // Enemy -> player direction, fired when a ScheduledTimer resolves (see
  // EnemyAttackSchedulingService). Flat damage straight off the static
  // attack data, matching applyDamage's existing lack of stat recalculation
  // above rather than inventing a separate defense formula here.
  Future<EnemyAttackDamageResult> applyEnemyAttackDamage(
      EnemyAttackData attack, Character character) async {
    final newHealth = (character.currentHealth - attack.damage)
        .clamp(0, character.maxHealth)
        .toInt();
    // The amount actually taken, not the raw attack stat — clamped at 0 HP
    // means a killing blow can deal less than its listed damage.
    final damageDealt = character.currentHealth - newHealth;
    final updated = character.copyWith(currentHealth: newHealth);
    final persisted = await characterRepository.updateCharacter(updated);
    return EnemyAttackDamageResult(
        character: persisted, damageDealt: damageDealt);
  }
}

class EnemyAttackDamageResult {
  final Character character;
  final int damageDealt;

  EnemyAttackDamageResult(
      {required this.character, required this.damageDealt});
}
