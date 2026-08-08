import 'package:questvale/data/models/stat_modifier.dart';
import 'package:questvale/data/skills/base_passive_skill.dart';

// The Skill System Foundations ticket's subtask-5 proof case — the only
// passive whose stat contribution is actually wired live so far (see
// statModifiers below). Mote Potency and Ice Ward are real classes too
// (see SkillService.getPassiveSkillById) but haven't had statModifiers
// overridden yet — that override is the entire remaining step to wire
// either of them in, once it's their turn.
class ElementalAffinity extends BasePassiveSkill {
  ElementalAffinity({
    super.id = 'mage-1-elemental_affinity',
    required super.data,
    required super.level,
  });

  @override
  String get description =>
      data.description.replaceAll('x%', percentText(data.primaryBaseValue));

  // Fire & Ice Damage, both — matches the vault's "Increase Fire and Ice
  // Damage by x%" wording. tier: level scales this the same way
  // equipment's own tier scales its modifiers, via
  // StatModifierType.skillTierValue (equipmentTierValue's skill-sourced
  // sibling) — at level 1 that's 0.05, matching data.primaryBaseValue
  // exactly, though the two aren't read from the same place:
  // skillTierValue is the actual seam PlayerStatModifierStats consults;
  // primaryBaseValue only drives this skill's own description text above.
  @override
  List<StatModifier> statModifiers(String characterId) {
    return [
      StatModifier(
        id: '$id:fire',
        location: StatModifierLocation.character,
        characterId: characterId,
        type: StatModifierType.fireDamage,
        tier: level,
      ),
      StatModifier(
        id: '$id:ice',
        location: StatModifierLocation.character,
        characterId: characterId,
        type: StatModifierType.iceDamage,
        tier: level,
      ),
    ];
  }
}
