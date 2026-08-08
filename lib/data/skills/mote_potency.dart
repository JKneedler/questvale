import 'package:questvale/data/skills/base_passive_skill.dart';

// Deliberately inert this pass (see the Skill System Foundations ticket,
// subtask 5) — a real, constructible class registered in
// SkillService.getPassiveSkillById, but statModifiers isn't overridden, so
// it contributes nothing yet. Wiring it in later means overriding
// statModifiers to emit a StatModifierType.motePotency contribution, the
// same shape ElementalAffinity already uses for fireDamage/iceDamage.
class MotePotency extends BasePassiveSkill {
  MotePotency({
    super.id = 'mage-1-mote_potency',
    required super.data,
    required super.level,
  });

  @override
  String get description =>
      data.description.replaceAll('x%', percentText(data.primaryBaseValue));
}
