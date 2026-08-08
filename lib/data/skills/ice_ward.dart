import 'package:questvale/data/skills/base_passive_skill.dart';

// Deliberately inert this pass (see the Skill System Foundations ticket,
// subtask 5) — a real, constructible class registered in
// SkillService.getPassiveSkillById, but statModifiers isn't overridden, so
// it contributes nothing yet. Wiring this in is a bigger step than Mote
// Potency's: "reduce the AP cost of Ice skills" doesn't have a matching
// StatModifierType yet (apEfficiency is generic, not element-scoped) —
// that's its own small piece of design work, not just an override.
class IceWard extends BasePassiveSkill {
  IceWard({
    super.id = 'mage-1-ice_ward',
    required super.data,
    required super.level,
  });

  @override
  String get description =>
      data.description.replaceAll('x%', percentText(data.primaryBaseValue));
}
