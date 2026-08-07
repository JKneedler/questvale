import 'dart:ui';

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
// the vault's Mage skill tree. Deliberately independent of damageType (a
// skill's element and its mote behavior are separate axes, even though
// every Tier 1 skill happens to couple them): Frost Armor is Ice-flavored
// but touches no motes at all, hence `none` as a real, common value rather
// than moteElement simply being left null on non-Mage skills only.
enum MoteInteractionType {
  none,
  generate,
  consume,
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
  final SkillDamageType? damageType;
  final int? apCost;
  // Hours; fractional (e.g. 0.5 for Firebolt) — not every Tier 1 cooldown
  // lands on a whole hour, unlike enemy attack timers so far.
  final double? cooldown;
  final SkillTargetingType? targetingType;
  final double? primaryBaseValue;
  final double? primaryValueScaler;
  final double? secondaryBaseValue;
  final double? secondaryValueScaler;
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
    this.damageType,
    this.apCost,
    this.cooldown,
    this.targetingType,
    this.primaryBaseValue,
    this.primaryValueScaler,
    this.secondaryBaseValue,
    this.secondaryValueScaler,
    this.moteInteraction = MoteInteractionType.none,
    this.moteElement,
  });

  @override
  String toString() {
    return 'SkillData(id: $id, characterClass: $characterClass, tier: $tier, name: $name, description: $description, iconPath: $iconPath, type: $type, damageType: $damageType, apCost: $apCost, cooldown: $cooldown, targetingType: $targetingType, primaryBaseValue: $primaryBaseValue, primaryValueScaler: $primaryValueScaler, secondaryBaseValue: $secondaryBaseValue, secondaryValueScaler: $secondaryValueScaler, moteInteraction: $moteInteraction, moteElement: $moteElement)';
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
      damageType: json['damageType'] != null
          ? SkillDamageType.values[json['damageType'] as int]
          : null,
      apCost: json['apCost'] as int?,
      cooldown: (json['cooldown'] as num?)?.toDouble(),
      targetingType: json['targetingType'] != null
          ? SkillTargetingType.values[json['targetingType'] as int]
          : null,
      primaryBaseValue: json['primaryBaseValue'] as double?,
      primaryValueScaler: json['primaryValueScaler'] as double?,
      secondaryBaseValue: json['secondaryBaseValue'] as double?,
      secondaryValueScaler: json['secondaryValueScaler'] as double?,
      moteInteraction: json['moteInteraction'] != null
          ? MoteInteractionType.values[json['moteInteraction'] as int]
          : MoteInteractionType.none,
      moteElement: json['moteElement'] != null
          ? MoteElement.values[json['moteElement'] as int]
          : null,
    );
  }
}
