import 'package:questvale/data/skills/base_passive_skill.dart';

// The Skill System Foundations ticket's subtask-5 proof case — the only
// passive whose stat contribution is actually wired live so far. No
// overrides needed: its skills.json data declares two statModifier-kind
// effect components (fireDamage and iceDamage, both real StatModifierTypes
// — matching the vault's "Increase Fire and Ice Damage by x%" wording), so
// BasePassiveSkill's generic description/statModifiers defaults handle it
// entirely (subtask 6). Mote Potency and Ice Ward are real classes too
// (see SkillService.getPassiveSkillById) but their data leaves
// statModifierType null — that's the entire remaining step to wire either
// of them in, once it's their turn, and it's a data change, not a code one.
class ElementalAffinity extends BasePassiveSkill {
  ElementalAffinity({
    super.id = 'mage-1-elemental_affinity',
    required super.data,
    required super.level,
  });
}
