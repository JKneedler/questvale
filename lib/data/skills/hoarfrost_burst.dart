import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/data/skills/frost_armor.dart';
import 'package:questvale/services/combat_service.dart';

class HoarfrostBurst extends BaseActiveSkill {
  HoarfrostBurst({
    super.id = 'mage-1-hoarfrost_burst',
    required super.data,
    required super.level,
  });

  @override
  String get description => data.description
      .replaceAll('x%', percentText(data.damageEffect?.baseValue));

  // Ice's mote payoff, symmetric with Ember Burst — damage scales with
  // Ice motes consumed (see EmberBurst's doc comment for the 0-consumed
  // case). The shield half (the shield-kind effect component, per mote
  // consumed, same %-of-max-HP-per-mote shape as the damage half) is this
  // skill's second consumer of StatusEffectService.applyShield alongside
  // Frost Armor (Skill System Foundations, subtask 4) — reuses FrostArmor.
  // shieldDuration rather than inventing its own number, since the vault
  // doesn't specify one for this skill.
  @override
  Future<void> execute(
      CombatService combatService,
      PlayerCombatStats playerCombatStats,
      List<Enemy> targettedEnemies,
      SkillCastContext context) async {
    final motesConsumed = context.moteResult.motesConsumed;
    final multiplier = (data.damageEffect?.baseValue ?? 0) * motesConsumed;
    await basicEnemyDamage(combatService, playerCombatStats, targettedEnemies,
        damageMultiplierOverride: multiplier);

    final shieldMagnitude = ((data.shieldEffect?.baseValue ?? 0) *
            motesConsumed *
            playerCombatStats.maxHealth)
        .round();
    await combatService.statusEffectService.applyShield(
      targetId: context.caster.id,
      encounterId: context.encounterId,
      magnitude: shieldMagnitude,
      duration: FrostArmor.shieldDuration,
    );
  }
}
