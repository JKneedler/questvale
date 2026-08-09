import 'package:questvale/data/skills/base_passive_skill.dart';

// The Skill System Foundations ticket's subtask-5 proof case — the only
// passive whose stat contribution is actually wired live so far. No
// overrides needed: its skills.json data declares two statModifier-kind
// effect components (fireDamage and iceDamage, both real StatModifierTypes
// — matching the vault's "Increase Fire and Ice Damage by x%" wording), so
// BasePassiveSkill's generic description/statModifiers defaults handle it
// entirely (subtask 6). Mote Potency is a real class too (see
// SkillService.getPassiveSkillById) but its data leaves statModifierType
// null — that's the entire remaining step to wire it in, once it's its
// turn, and it's a data change, not a code one. Ice Ward (AP-cost
// reduction for Ice skills) was removed — individual skills modifying AP
// cost isn't a mechanic this game wants.
class ElementalAffinity extends BasePassiveSkill {
  ElementalAffinity({
    super.id = 'mage-1-elemental_affinity',
    required super.data,
    required super.level,
  });
}
