import 'package:questvale/data/models/stat_modifier.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';

abstract class BasePassiveSkill {
  final String id;
  final SkillData data;
  final int level;

  BasePassiveSkill({
    required this.id,
    required this.data,
    required this.level,
  });

  String get description;

  // Shared 'x%' description-template formatter — mirrors
  // BaseActiveSkill.percentText exactly (primaryBaseValue etc. are stored
  // as fractions, 1.5 == 150%).
  String percentText(double? value) => '${((value ?? 0) * 100).round()}%';

  // Stat modifiers this passive contributes while equipped/invested — see
  // PlayerStatModifierStats.fromStatModifiers's passiveModifiers param
  // (Skill System Foundations ticket, subtask 5). tier on the returned
  // StatModifiers should be `level`, so they scale via
  // StatModifierType.skillTierValue the same way an equipped item's own
  // modifiers scale via equipmentTierValue.
  //
  // Defaults to none — most passives registered in SkillService
  // (getPassiveSkillById) don't override this yet (Mote Potency, Ice
  // Ward): they exist as real, constructible classes, but are
  // deliberately left inert until it's their turn to be wired in.
  // Overriding this method with their actual contribution is the entire
  // remaining step — see ElementalAffinity for the reference case.
  List<StatModifier> statModifiers(String characterId) => const [];
}
