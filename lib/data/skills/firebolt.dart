import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/services/combat_service.dart';

class Firebolt extends BaseActiveSkill {
  Firebolt({
    super.id = 'mage-1-firebolt',
    required super.data,
    required super.level,
  });

  @override
  String get description =>
      data.description.replaceAll('x%', percentText(data.primaryBaseValue));

  // Fire's mote generator (see SkillData.moteInteraction/moteElement on
  // this skill's data — CombatCubit already resolved the generate call
  // into moteResult before this runs). Damage is real; the 20% Burn proc
  // chance (data.secondaryBaseValue) is captured as data for whenever the
  // vault's Status Effects system gets a runtime model in this codebase —
  // there's nothing to apply Burn to yet, so it isn't rolled here.
  @override
  Future<void> execute(
      CombatService combatService,
      PlayerCombatStats playerCombatStats,
      List<Enemy> targettedEnemies,
      SkillCastContext context) async {
    await basicEnemyDamage(combatService, playerCombatStats, targettedEnemies);
  }
}
