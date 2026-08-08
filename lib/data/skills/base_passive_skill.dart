import 'package:collection/collection.dart';
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

  // Shared 'x%' description-template formatter — mirrors
  // BaseActiveSkill.percentText exactly (a SkillEffectComponent's
  // baseValue is stored as a fraction, 1.5 == 150%).
  String percentText(double? value) => '${((value ?? 0) * 100).round()}%';

  // Generic default: substitutes the first statModifier-kind effect
  // component's baseValue into the skill's description template. Every
  // Tier 1 passive fits this shape (one flat % bonus, one description
  // slot) — override if a future passive's description needs something
  // more specific.
  String get description => data.description
      .replaceAll('x%', percentText(data.statModifierEffects.firstOrNull?.baseValue));

  // Stat modifiers this passive contributes while equipped/invested — see
  // PlayerStatModifierStats.fromStatModifiers's passiveModifiers param
  // (Skill System Foundations ticket, subtask 5). Generic default:
  // converts every statModifier-kind effect component that declares a
  // real StatModifierType (subtask 6) into a StatModifier for
  // `characterId`, tier: level, so it scales via
  // StatModifierType.skillTierValue the same way an equipped item's own
  // modifiers scale via equipmentTierValue.
  //
  // Mote Potency and Ice Ward's data deliberately leaves statModifierType
  // null on their effect components (see their own skills.json entries) —
  // not because this method can't handle them, but because that's the
  // actual "stay inert" decision from subtask 5: wiring either one in
  // later is a pure data change (set statModifierType), no code required.
  // Override this method if a future passive needs real conditional logic
  // instead of a flat per-level value (e.g. a stacking bonus).
  List<StatModifier> statModifiers(String characterId) {
    return data.statModifierEffects
        .where((e) => e.statModifierType != null)
        .map((e) => StatModifier(
              id: '$id:${e.statModifierType!.name}',
              location: StatModifierLocation.character,
              characterId: characterId,
              type: e.statModifierType!,
              tier: level,
            ))
        .toList();
  }
}
