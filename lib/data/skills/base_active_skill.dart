import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/services/combat_service.dart';

abstract class BaseActiveSkill {
  final String id;
  final SkillData data;
  final int level;

  BaseActiveSkill({
    required this.id,
    required this.data,
    required this.level,
  });

  String get description;

  // Shared 'x%' description-template formatter — a SkillEffectComponent's
  // baseValue is stored as a fraction (1.5 == 150%), so every skill needs
  // the same *100 conversion when substituting into its description
  // string.
  String percentText(double? value) => '${((value ?? 0) * 100).round()}%';

  // Same template `description` renders, but with the real, already-
  // computed final amount substituted for the level-scaled percentage —
  // used specifically by the combat screen's skill-target view
  // (QuestVitalsAndSkillsCard's _SkillTargetContent), where (unlike the
  // Skills Gear-Up/upgrade screen `description` itself is written for,
  // which has no caster to compute real stats against yet) the actual
  // number a cast will deal/grant is fully knowable ahead of casting.
  // Default falls back to `description` verbatim; only skills with a real
  // damage/shield component need to override it — see each subclass.
  String combatDescription(PlayerCombatStats playerCombatStats) => description;

  // Shared rounding helper for combatDescription overrides — the same
  // math basicEnemyDamage/CombatService.applyDamage ultimately run
  // (valueAtLevel * attackPowerFor(damageType)), so a shown number can't
  // drift from what actually lands when the skill is cast.
  int realDamageAmount(PlayerCombatStats playerCombatStats) {
    final damage = data.damageEffect;
    if (damage == null) return 0;
    return (damage.valueAtLevel(level) *
            playerCombatStats
                .attackPowerFor(damage.damageType ?? SkillDamageType.physical))
        .round();
  }

  // Shared rounding helper mirroring StatusEffectService.applyShield's own
  // magnitude math (see FrostArmor/HoarfrostBurst's execute()).
  int realShieldAmount(PlayerCombatStats playerCombatStats) {
    final shield = data.shieldEffect;
    if (shield == null) return 0;
    return (shield.valueAtLevel(level) * playerCombatStats.maxHealth).round();
  }

  // context is everything CombatService.castSkill already resolved before
  // execute() ever runs — AP was checked/spent, the cooldown was checked/
  // armed, and the caster's class resource (Mote generation/consumption for
  // Mage; nothing yet for Warrior/Rogue) was resolved via
  // ClassResourceResolver. Mage skills read context.moteResult exactly like
  // they used to read the old bare moteResult parameter this replaced.
  // Skills that don't interact with any of that can just ignore it.
  Future<void> execute(
      CombatService combatService,
      PlayerCombatStats playerCombatStats,
      List<Enemy> targettedEnemies,
      SkillCastContext context) async {
    return;
  }

  // damageMultiplierOverride lets a mote-consumer skill (Ember Burst,
  // Hoarfrost Burst) pass a multiplier computed from motesConsumed instead
  // of the flat data.damageEffect.baseValue every other skill uses as-is.
  Future<List<DamageResult>> basicEnemyDamage(
    CombatService combatService,
    PlayerCombatStats playerCombatStats,
    List<Enemy> enemies, {
    double? damageMultiplierOverride,
  }) async {
    final damageEffect = data.damageEffect;
    List<DamageResult> damageResults = [];
    for (int i = 0; i < enemies.length; i++) {
      if (data.targetingType == SkillTargetingType.singleEnemy && i != 0) break;

      final damageData = DamageData(
          damageMultiplier: damageMultiplierOverride ??
              damageEffect?.valueAtLevel(level) ??
              1,
          damageType: damageEffect?.damageType ?? SkillDamageType.physical);
      final damageResult = await combatService.applyDamage(
          damageData, playerCombatStats, enemies[i].id);
      print(
          '${data.name} dealt ${damageResult.damageDone} damage to ${enemies[i].id} and ${damageResult.didKill ? 'killed' : 'did not kill'} it');
      damageResults.add(damageResult);
    }
    return damageResults;
  }
}
