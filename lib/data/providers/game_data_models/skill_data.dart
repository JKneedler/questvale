import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:questvale/data/models/stat_modifier.dart';
import 'package:questvale/helpers/shared_enums.dart';

enum SkillType {
  active,
  passive,
}

enum SkillTargetingType {
  self,
  singleEnemy,
  allEnemies,
}

enum SkillButtonColor {
  weaponType,
  fireRed,
  iceBlue,
  arcanePurple;

  String get borderImagePath => {
        SkillButtonColor.weaponType:
            'images/ui/borders/skills/skill-border-weapon-type.png',
        SkillButtonColor.fireRed:
            'images/ui/borders/skills/skill-border-fire-red.png',
        SkillButtonColor.iceBlue:
            'images/ui/borders/skills/skill-border-ice-blue.png',
        SkillButtonColor.arcanePurple:
            'images/ui/borders/skills/skill-border-weapon-type.png',
      }[this]!;

  Color get backgroundColor => {
        SkillButtonColor.weaponType: Color(0xFF200A2D),
        SkillButtonColor.fireRed: Color(0xFF4A0C0A),
        SkillButtonColor.iceBlue: Color(0xFF0C2034),
        SkillButtonColor.arcanePurple: Color(0xFF200A2D),
      }[this]!;

  // Dominant trim color sampled from each border PNG's most common opaque
  // pixel (arcanePurple has no border art of its own yet, same as
  // borderImagePath above, so it mirrors weaponType's).
  Color get primaryColor => {
        SkillButtonColor.weaponType: Color(0xFF6A2BAA),
        SkillButtonColor.fireRed: Color(0xFFC22F27),
        SkillButtonColor.iceBlue: Color(0xFF367AE0),
        SkillButtonColor.arcanePurple: Color(0xFF6A2BAA),
      }[this]!;
}

enum SkillDamageType {
  weaponType,
  physical,
  fire,
  ice,
  poison;

  String get name => {
        SkillDamageType.weaponType: 'Weapon Type',
        SkillDamageType.physical: 'Physical',
        SkillDamageType.fire: 'Fire',
        SkillDamageType.ice: 'Ice',
        SkillDamageType.poison: 'Poison',
      }[this]!;
}

// What a skill does to the caster's Mote bank on a successful cast — see
// the vault's Mage skill tree. Deliberately independent of a damage
// component's own damageType (a skill's element and its mote behavior are
// separate axes, even though every Tier 1 skill happens to couple them):
// Frost Armor is Ice-flavored but touches no motes at all, hence `none` as
// a real, common value rather than moteElement simply being left null on
// non-Mage skills only.
enum MoteInteractionType {
  none,
  generate,
  consume,
}

// What a single numeric knob on a skill actually does — see the Skill
// System Foundations ticket, subtask 6. Replaces the old fixed
// primaryBaseValue/secondaryBaseValue pair, which was already straining
// under Tier 1 (Hoarfrost Burst needs damage AND shield off two different
// values) and wouldn't fit several roadmapped Tier 2 skills (Thermal
// Shift's stance-alternation, Meteor Storm's multi-hit). A skill now
// declares a `List<SkillEffectComponent>` instead, and execute()
// implementations read components by kind (see SkillData's damageEffect/
// shieldEffect/statusEffectChances/statModifierEffects getters) rather
// than by position.
enum SkillEffectKind {
  damage,
  shield,
  statusEffectChance,
  // A passive's flat stat bonus (Elemental Affinity's fireDamage/iceDamage,
  // Mote Potency's motePotency, ...) — see BasePassiveSkill.statModifiers,
  // which reads these instead of hardcoding its own numbers.
  statModifier,
}

class SkillEffectComponent {
  final SkillEffectKind kind;
  final double baseValue;
  // Reserved for future level-based scaling (Lv1→Lv5) — replaces the old
  // primaryValueScaler/secondaryValueScaler fields, which were themselves
  // never actually consumed anywhere (no skill-leveling system exists
  // yet). Still just data until that system exists.
  final double? valueScaler;
  // Only meaningful for kind == damage — which element this component's
  // damage is. Lives per-component (not per-skill, as the old top-level
  // SkillData.damageType did) so a future hybrid skill can have e.g. one
  // Fire damage component and one Ice damage component side by side.
  final SkillDamageType? damageType;
  // Only meaningful for kind == statusEffectChance — which status effect
  // this component's proc chance applies to.
  final StatusEffectType? statusEffectType;
  // Only meaningful for kind == statModifier — which stat this passive's
  // bonus affects. Null is valid even for a real statModifier component
  // (Ice Ward's AP-cost reduction doesn't have a matching StatModifierType
  // yet — see IceWard's own doc comment) — the component still carries a
  // baseValue for its description text even though nothing consumes
  // statModifierType for it.
  final StatModifierType? statModifierType;

  const SkillEffectComponent({
    required this.kind,
    required this.baseValue,
    this.valueScaler,
    this.damageType,
    this.statusEffectType,
    this.statModifierType,
  });

  @override
  String toString() =>
      'SkillEffectComponent(kind: $kind, baseValue: $baseValue, valueScaler: $valueScaler, damageType: $damageType, statusEffectType: $statusEffectType, statModifierType: $statModifierType)';

  factory SkillEffectComponent.fromJson(Map<String, dynamic> json) {
    return SkillEffectComponent(
      kind: SkillEffectKind.values[json['kind'] as int],
      baseValue: (json['baseValue'] as num).toDouble(),
      valueScaler: (json['valueScaler'] as num?)?.toDouble(),
      damageType: json['damageType'] != null
          ? SkillDamageType.values[json['damageType'] as int]
          : null,
      statusEffectType: json['statusEffectType'] != null
          ? StatusEffectType.values[json['statusEffectType'] as int]
          : null,
      statModifierType: json['statModifierType'] != null
          ? StatModifierType.values[json['statModifierType'] as int]
          : null,
    );
  }
}

class SkillData {
  final String id;
  final CharacterClass characterClass;
  final int tier;
  final String name;
  final String description;
  final String iconPath;
  final SkillButtonColor buttonColor;
  final SkillType type;
  final int? apCost;
  // Hours; fractional (e.g. 0.5 for Firebolt) — not every Tier 1 cooldown
  // lands on a whole hour, unlike enemy attack timers so far.
  final double? cooldown;
  final SkillTargetingType? targetingType;
  final List<SkillEffectComponent> effects;
  // Defaults to none/null for every non-Mage skill, and for Mage skills
  // that don't touch the bank (Arcane Bolt, Frost Armor, the passives).
  final MoteInteractionType moteInteraction;
  final MoteElement? moteElement;

  const SkillData({
    required this.id,
    required this.characterClass,
    required this.tier,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.buttonColor,
    this.apCost,
    this.cooldown,
    this.targetingType,
    this.effects = const [],
    this.moteInteraction = MoteInteractionType.none,
    this.moteElement,
  });

  // The one damage component a skill has this pass — every Tier 1 skill
  // that deals damage has exactly one. A skill with more than one (a
  // future hybrid multi-element hit) will need its consumer to read
  // `effects` directly instead of this convenience getter; that's a
  // deliberate limitation, not an oversight — see the ticket's out-of-scope
  // note on not building Tier 2 content here.
  SkillEffectComponent? get damageEffect =>
      effects.firstWhereOrNull((e) => e.kind == SkillEffectKind.damage);

  SkillEffectComponent? get shieldEffect =>
      effects.firstWhereOrNull((e) => e.kind == SkillEffectKind.shield);

  List<SkillEffectComponent> get statusEffectChances =>
      effects.where((e) => e.kind == SkillEffectKind.statusEffectChance).toList();

  List<SkillEffectComponent> get statModifierEffects =>
      effects.where((e) => e.kind == SkillEffectKind.statModifier).toList();

  @override
  String toString() {
    return 'SkillData(id: $id, characterClass: $characterClass, tier: $tier, name: $name, description: $description, iconPath: $iconPath, type: $type, apCost: $apCost, cooldown: $cooldown, targetingType: $targetingType, effects: $effects, moteInteraction: $moteInteraction, moteElement: $moteElement)';
  }

  factory SkillData.fromJson(Map<String, dynamic> json) {
    return SkillData(
      id: json['id'] as String,
      characterClass: CharacterClass.values[json['class'] as int],
      tier: json['tier'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      iconPath: json['iconPath'] as String,
      type: SkillType.values[json['type'] as int],
      buttonColor: SkillButtonColor.values[json['buttonColor'] as int],
      apCost: json['apCost'] as int?,
      cooldown: (json['cooldown'] as num?)?.toDouble(),
      targetingType: json['targetingType'] != null
          ? SkillTargetingType.values[json['targetingType'] as int]
          : null,
      effects: json['effects'] != null
          ? (json['effects'] as List<dynamic>)
              .map((e) => SkillEffectComponent.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      moteInteraction: json['moteInteraction'] != null
          ? MoteInteractionType.values[json['moteInteraction'] as int]
          : MoteInteractionType.none,
      moteElement: json['moteElement'] != null
          ? MoteElement.values[json['moteElement'] as int]
          : null,
    );
  }
}
