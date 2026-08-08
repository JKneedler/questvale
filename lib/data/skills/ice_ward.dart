import 'package:questvale/data/skills/base_passive_skill.dart';

// Deliberately inert this pass (see the Skill System Foundations ticket,
// subtask 5) — a real, constructible class registered in
// SkillService.getPassiveSkillById. Its skills.json data has a
// statModifier-kind effect component (so its description still shows the
// right percentage via BasePassiveSkill's generic default), but that
// component's statModifierType is left null. Wiring this in is a bigger
// step than Mote Potency's: "reduce the AP cost of Ice skills" doesn't
// have a matching StatModifierType yet (apEfficiency is generic, not
// element-scoped) — that's its own small piece of design work, not just a
// data change.
class IceWard extends BasePassiveSkill {
  IceWard({
    super.id = 'mage-1-ice_ward',
    required super.data,
    required super.level,
  });
}
