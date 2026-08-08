import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/services/combat_service.dart';

// Deliberately mote-free (see the vault's Mage skill tree — "not every
// skill needs to touch the system"). A pure self-shield, now wired
// end-to-end via StatusEffectService.applyShield (Skill System
// Foundations, subtask 4) — the shield's own absorb-then-carry-through
// mechanic lives there, not in this skill.
class FrostArmor extends BaseActiveSkill {
  // Shield duration belongs to Frost Armor (the source) — vault: "for
  // 12h". Deliberately longer than this skill's own 6h cooldown; see
  // StatusEffectService.applyShield's doc comment for why that's the
  // intended recast loop, not an edge case.
  static const shieldDuration = Duration(hours: 12);

  FrostArmor({
    super.id = 'mage-1-frost_armor',
    required super.data,
    required super.level,
  });

  @override
  String get description =>
      data.description.replaceAll('x%', percentText(data.primaryBaseValue));

  @override
  Future<void> execute(
      CombatService combatService,
      PlayerCombatStats playerCombatStats,
      List<Enemy> targettedEnemies,
      SkillCastContext context) async {
    final magnitude =
        ((data.primaryBaseValue ?? 0) * playerCombatStats.maxHealth).round();
    await combatService.statusEffectService.applyShield(
      targetId: context.caster.id,
      encounterId: context.encounterId,
      magnitude: magnitude,
      duration: shieldDuration,
    );
  }
}
