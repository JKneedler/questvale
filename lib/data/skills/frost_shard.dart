import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/services/combat_service.dart';

class FrostShard extends BaseActiveSkill {
  FrostShard({
    super.id = 'mage-1-frost_shard',
    required super.data,
    required super.level,
  });

  @override
  String get description =>
      data.description.replaceAll('x%', percentText(data.primaryBaseValue));

  // Ice's mote generator, symmetric with Firebolt. The 20% Slow proc
  // chance (data.secondaryBaseValue) is captured as data for the same
  // not-yet-built reason as Firebolt's Burn proc — see that class's doc
  // comment.
  @override
  Future<void> execute(
      CombatService combatService,
      PlayerCombatStats playerCombatStats,
      List<Enemy> targettedEnemies,
      SkillCastContext context) async {
    await basicEnemyDamage(combatService, playerCombatStats, targettedEnemies);
  }
}
