import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/services/combat_service.dart';
import 'package:questvale/services/mote_service.dart';

class HoarfrostBurst extends BaseActiveSkill {
  HoarfrostBurst({
    super.id = 'mage-1-hoarfrost_burst',
    required super.data,
    required super.level,
  });

  @override
  String get description =>
      data.description.replaceAll('x%', percentText(data.primaryBaseValue));

  // Ice's mote payoff, symmetric with Ember Burst — damage scales with
  // Ice motes consumed (see EmberBurst's doc comment for the 0-consumed
  // case). The vault also specs a shield component
  // (data.secondaryBaseValue, per mote consumed) that deliberately isn't
  // applied here: there's no shield/buff mechanic on Character in this
  // codebase yet (nothing tracks a temporary damage-absorbing pool), so
  // only the damage half of this skill actually fires. Adding that
  // mechanic is its own piece of work, not something to bolt on inside a
  // single skill's execute().
  @override
  Future<void> execute(
      CombatService combatService,
      PlayerCombatStats playerCombatStats,
      List<Enemy> targettedEnemies,
      MoteInteractionResult moteResult) async {
    final multiplier =
        (data.primaryBaseValue ?? 0) * moteResult.motesConsumed;
    await basicEnemyDamage(combatService, playerCombatStats, targettedEnemies,
        damageMultiplierOverride: multiplier);
  }
}
