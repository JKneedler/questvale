import 'dart:math';

import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/services/combat_service.dart';

class FrostShard extends BaseActiveSkill {
  // Injectable for deterministic proc-roll tests, same pattern as
  // EnemyAttackSchedulingService.selectMove's optional Random.
  final Random random;

  // Slow's duration belongs to Frost Shard (the source) — vault: "Slow
  // target by 50% for 8h". The 50% rate itself is intrinsic to what Slow
  // means (StatusEffectService.slowRateMultiplier), not a per-skill knob.
  static const slowDuration = Duration(hours: 8);

  FrostShard({
    super.id = 'mage-1-frost_shard',
    required super.data,
    required super.level,
    Random? random,
  }) : random = random ?? Random();

  @override
  String get description =>
      data.description.replaceAll('x%', percentText(data.primaryBaseValue));

  // Ice's mote generator, symmetric with Firebolt. Slow's 20% proc chance
  // (data.secondaryBaseValue) is the reference rate-modifier case for the
  // Skill System Foundations ticket's status-effect runtime model —
  // rolled here, applied via StatusEffectService if it lands. Only ever
  // targets an enemy's enemyMove timer so far — nothing casts Slow at a
  // player yet.
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

    await combatService.statusEffectService.applySlow(
      targetId: targettedEnemies.first.id,
      encounterId: context.encounterId,
      affectedTimerKind: ScheduledTimerKind.enemyMove,
      duration: slowDuration,
    );
  }
}
