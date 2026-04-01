import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/services/combat_service.dart';

class ArcaneBolt extends BaseActiveSkill {
  ArcaneBolt({
    super.id = 'mage-1-arcane_bolt',
    required super.data,
    required super.level,
  });

  @override
  String get description =>
      data.description.replaceAll('x%', '${data.primaryBaseValue}%');

  @override
  Future<void> execute(CombatService combatService,
      PlayerCombatStats playerCombatStats, List<Enemy> targettedEnemies) async {
    final List<DamageResult> damageResults = await basicEnemyDamage(
        combatService, playerCombatStats, targettedEnemies);
    print('Arcane Bolt executed');
  }
}
