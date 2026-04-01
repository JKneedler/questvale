import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/services/combat_service.dart';

class ElementalSurge extends BaseActiveSkill {
  ElementalSurge({
    super.id = 'mage-1-elemental_surge',
    required super.data,
    required super.level,
  });

  @override
  String get description => data.description
      .replaceAll('x%', '${(data.primaryBaseValue ?? 0) * 100}%');

  @override
  Future<void> execute(CombatService combatService,
      PlayerCombatStats playerCombatStats, List<Enemy> targettedEnemies) async {
    final List<DamageResult> damageResults = await basicEnemyDamage(
        combatService, playerCombatStats, targettedEnemies);
    print('Elemental Surge executed');
  }
}
