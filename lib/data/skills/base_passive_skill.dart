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
  // component's *actual contributed value at this passive's level* into
  // the skill's description template — reads through
  // StatModifierType.skillTierValue(level), the same call statModifiers()
  // below makes, so the description can never show a different number
  // than what's really being applied. Falls back to the component's flat
  // baseValue when statModifierType is null (Mote Potency's
  // deliberately-inert data — skillTierValue has no type to call).
  //
  // Note this is a different (and, past level 1, numerically different)
  // curve than SkillEffectComponent.valueAtLevel, which governs active
  // skills' damage/shield magnitudes — skillTierValue is StatModifier's
  // pre-existing tier-scaling mechanism, shared with equipment's
  // equipmentTierValue, and passives were wired onto it in subtask 5
  // before valueAtLevel existed. Unifying the two is a bigger change
  // (StatModifier would need to carry a real per-component value instead
  // of a type+tier lookup) than this pass's scope.
  String get description {
    final effect = data.statModifierEffects.firstOrNull;
    final displayValue = effect?.statModifierType != null
        ? effect!.statModifierType!.skillTierValue(level)
        : effect?.baseValue;
    return data.description.replaceAll('x%', percentText(displayValue));
  }

  // Stat modifiers this passive contributes while equipped/invested — see
  // PlayerStatModifierStats.fromStatModifiers's passiveModifiers param
  // (Skill System Foundations ticket, subtask 5). Generic default:
  // converts every statModifier-kind effect component that declares a
  // real StatModifierType (subtask 6) into a StatModifier for
  // `characterId`, tier: level, so it scales via
  // StatModifierType.skillTierValue the same way an equipped item's own
  // modifiers scale via equipmentTierValue.
  //
  // Mote Potency's data deliberately leaves statModifierType null on its
  // effect component (see its own skills.json entry) — not because this
  // method can't handle it, but because that's the actual "stay inert"
  // decision from subtask 5: wiring it in later is a pure data change
  // (set statModifierType), no code required.
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
