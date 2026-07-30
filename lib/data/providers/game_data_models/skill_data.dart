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
  final int? cooldown;
  final int? manaCost;
  final SkillTargetingType? targetingType;
  final double? primaryBaseValue;
  final double? primaryValueScaler;
  final double? secondaryBaseValue;
  final double? secondaryValueScaler;

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
    this.manaCost,
    this.targetingType,
    this.primaryBaseValue,
    this.primaryValueScaler,
    this.secondaryBaseValue,
    this.secondaryValueScaler,
  });

  @override
  String toString() {
    return 'SkillData(id: $id, characterClass: $characterClass, tier: $tier, name: $name, description: $description, iconPath: $iconPath, type: $type, damageType: $damageType, apCost: $apCost, cooldown: $cooldown, manaCost: $manaCost, targetingType: $targetingType, primaryBaseValue: $primaryBaseValue, primaryValueScaler: $primaryValueScaler, secondaryBaseValue: $secondaryBaseValue, secondaryValueScaler: $secondaryValueScaler)';
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
      cooldown: json['cooldown'] as int?,
      manaCost: json['manaCost'] as int?,
      targetingType: json['targetingType'] != null
          ? SkillTargetingType.values[json['targetingType'] as int]
          : null,
      primaryBaseValue: json['primaryBaseValue'] as double?,
      primaryValueScaler: json['primaryValueScaler'] as double?,
      secondaryBaseValue: json['secondaryBaseValue'] as double?,
      secondaryValueScaler: json['secondaryValueScaler'] as double?,
    );
  }
}
