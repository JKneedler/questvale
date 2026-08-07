import 'package:questvale/data/skills/base_active_skill.dart';

// Deliberately mote-free (see the vault's Mage skill tree — "not every
// skill needs to touch the system"). A pure self-shield: there's no
// shield/buff mechanic on Character in this codebase yet (no temporary
// damage-absorbing pool tracked anywhere), so this skill "exists" as real
// data (name, cost, cooldown, targeting) but has no execute() override of
// its own — it inherits BaseActiveSkill's no-op default rather than fake
// an effect that can't actually apply. Wiring the shield itself is its own
// piece of work, same gap Hoarfrost Burst's shield half is waiting on.
class FrostArmor extends BaseActiveSkill {
  FrostArmor({
    super.id = 'mage-1-frost_armor',
    required super.data,
    required super.level,
  });

  @override
  String get description =>
      data.description.replaceAll('x%', percentText(data.primaryBaseValue));
}
