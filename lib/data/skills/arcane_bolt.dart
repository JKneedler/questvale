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
  String get description => data.description
      .replaceAll('x%', percentText(data.damageEffect?.baseValue));

  // Deliberately mote-free (see SkillData.moteInteraction on this skill's
  // data) — context.moteResult is always MoteInteractionResult.none for
  // Arcane Bolt, so context is unused here. Also the class's 0-cooldown
  // basic: CombatService.castSkill doesn't arm a cooldown timer for it at
  // all since data.cooldown is 0.
  @override
  Future<void> execute(
      CombatService combatService,
      PlayerCombatStats playerCombatStats,
      List<Enemy> targettedEnemies,
      SkillCastContext context) async {
    await basicEnemyDamage(combatService, playerCombatStats, targettedEnemies);
  }
}
