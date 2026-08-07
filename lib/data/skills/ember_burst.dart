import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/services/combat_service.dart';
import 'package:questvale/services/mote_service.dart';

class EmberBurst extends BaseActiveSkill {
  EmberBurst({
    super.id = 'mage-1-ember_burst',
    required super.data,
    required super.level,
  });

  @override
  String get description =>
      data.description.replaceAll('x%', percentText(data.primaryBaseValue));

  // Fire's mote payoff — CombatCubit already resolved the consume-all call
  // into moteResult before this runs, so motesConsumed is however many Fire
  // motes were actually banked (0 is a valid, if wasteful, outcome — Tier 1
  // has no minimum-mote require-gate, that's a Tier 2+ concept). Damage
  // scales linearly with that count; no separate resource-spend mechanic —
  // this still just costs the skill's own AP/cooldown.
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
