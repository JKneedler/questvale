import 'package:questvale/data/skills/base_passive_skill.dart';

// Deliberately inert this pass (see the Skill System Foundations ticket,
// subtask 5) — a real, constructible class registered in
// SkillService.getPassiveSkillById. Its skills.json data has a
// statModifier-kind effect component (so its description still shows the
// right percentage via BasePassiveSkill's generic default), but that
// component's statModifierType is left null, so
// BasePassiveSkill.statModifiers contributes nothing yet. Wiring it in
// later means setting statModifierType to motePotency in the data — no
// code change needed (see subtask 6).
class MotePotency extends BasePassiveSkill {
  MotePotency({
    super.id = 'mage-1-mote_potency',
    required super.data,
    required super.level,
  });
}
