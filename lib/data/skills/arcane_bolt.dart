import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/services/combat_service.dart';
import 'package:questvale/services/mote_service.dart';

class ArcaneBolt extends BaseActiveSkill {
  ArcaneBolt({
    super.id = 'mage-1-arcane_bolt',
    required super.data,
    required super.level,
  });

  @override
  String get description =>
      data.description.replaceAll('x%', percentText(data.primaryBaseValue));

  // Deliberately mote-free (see SkillData.moteInteraction on this skill's
  // data) — moteResult is always MoteInteractionResult.none for Arcane
  // Bolt, so it's unused here.
  @override
  Future<void> execute(
      CombatService combatService,
      PlayerCombatStats playerCombatStats,
      List<Enemy> targettedEnemies,
      MoteInteractionResult moteResult) async {
    await basicEnemyDamage(combatService, playerCombatStats, targettedEnemies);
  }
}
