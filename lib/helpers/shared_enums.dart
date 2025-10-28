import 'package:flutter/material.dart';

enum CharacterClass {
  warrior,
  rogue,
  mage;

  int get baseMaxHealth {
    switch (this) {
      case CharacterClass.warrior:
        return 100;
      case CharacterClass.rogue:
        return 80;
      case CharacterClass.mage:
        return 60;
    }
  }
}

enum Rarity {
  common,
  uncommon,
  rare,
  epic,
  legendary;

  int get goldCost {
    switch (this) {
      case Rarity.common:
        return 100;
      case Rarity.uncommon:
        return 200;
      case Rarity.rare:
        return 300;
      case Rarity.epic:
        return 400;
      case Rarity.legendary:
        return 500;
      default:
        return 1;
    }
  }
}

enum DamageType {
  physical,
  fire,
  ice,
  poison;

  Color get color {
    switch (this) {
      case DamageType.physical:
        return Color(0xffD4A373);
      case DamageType.fire:
        return Color(0xffFF6B3D);
      case DamageType.ice:
        return Color(0xff3DA9FF);
      // case DamageType.air:
      // return Color(0xffD8F4FF);
      case DamageType.poison:
        return Color(0xff9BDB3B);
      // case DamageType.holy:
      //   return Color(0xffFFF275);
      // case DamageType.dark:
      //   return Color(0xff8E5CFF);
      default:
        return Colors.grey;
    }
  }
}
