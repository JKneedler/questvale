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

  Future<void> execute(CombatService combatService,
      PlayerCombatStats playerCombatStats, List<Enemy> targettedEnemies) async {
    return;
  }

  Future<List<DamageResult>> basicEnemyDamage(CombatService combatService,
      PlayerCombatStats playerCombatStats, List<Enemy> enemies) async {
    List<DamageResult> damageResults = [];
    for (int i = 0; i < enemies.length; i++) {
      if (data.targetingType == SkillTargetingType.singleEnemy && i != 0) break;

      final damageData = DamageData(
          damageMultiplier: data.primaryBaseValue ?? 1,
          damageType: data.damageType ?? SkillDamageType.physical);
      final damageResult =
          await combatService.applyDamage(damageData, enemies[i].id);
      print(
          '${data.name} dealt ${damageResult.damageDone} damage to ${enemies[i].id} and ${damageResult.didKill ? 'killed' : 'did not kill'} it');
      damageResults.add(damageResult);
    }
    return damageResults;
  }
}
