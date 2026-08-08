import 'dart:math';

import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/services/combat_service.dart';

class Firebolt extends BaseActiveSkill {
  // Injectable for deterministic proc-roll tests, same pattern as
  // EnemyAttackSchedulingService.selectMove's optional Random.
  final Random random;

  // Burn's per-application shape belongs to Firebolt (the source), not to
  // StatusEffectService (which only owns Burn's intrinsic tick cadence) —
  // vault: "5% ATK over 6h".
  static const burnDuration = Duration(hours: 6);
  static const burnMagnitudePercentOfAttackPower = 0.05;

  Firebolt({
    super.id = 'mage-1-firebolt',
    required super.data,
    required super.level,
    Random? random,
  }) : random = random ?? Random();

  @override
  String get description =>
      data.description.replaceAll('x%', percentText(data.primaryBaseValue));

  // Fire's mote generator (see SkillData.moteInteraction/moteElement on
  // this skill's data — CombatService.castSkill already resolved the
  // generate call into context.moteResult before this runs). Burn's 20%
  // proc chance (data.secondaryBaseValue) is the reference DoT case for
  // the Skill System Foundations ticket's status-effect runtime model —
  // rolled here, applied via StatusEffectService if it lands. Skipped
  // entirely if the hit killed the target (nothing left to burn).
  @override
  Future<void> execute(
      CombatService combatService,
      PlayerCombatStats playerCombatStats,
      List<Enemy> targettedEnemies,
      SkillCastContext context) async {
    final damageResults =
        await basicEnemyDamage(combatService, playerCombatStats, targettedEnemies);
    if (targettedEnemies.isEmpty || damageResults.isEmpty) return;
    if (damageResults.first.didKill) return;

    final procChance = data.secondaryBaseValue ?? 0;
    if (random.nextDouble() >= procChance) return;

    // Snapshotted now, at cast time — Burn ticks later reuse this exact
    // number rather than re-reading the caster's (possibly changed) stats
    // at tick time. See StatusEffectService.applyBurn's doc comment.
    final tickDamage =
        (burnMagnitudePercentOfAttackPower * playerCombatStats.fireAttackPower)
            .round();
    await combatService.statusEffectService.applyBurn(
      targetId: targettedEnemies.first.id,
      encounterId: context.encounterId,
      tickDamage: tickDamage,
      applicationDuration: burnDuration,
    );
  }
}
