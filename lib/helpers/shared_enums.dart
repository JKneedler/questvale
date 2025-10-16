import 'package:flutter/material.dart';

enum Rarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
  mythic,
}

enum DamageType {
  physical,
  fire,
  ice,
  air,
  poison,
  holy,
  dark;

  Color get color {
    switch (this) {
      case DamageType.physical:
        return Color(0xffD4A373);
      case DamageType.fire:
        return Color(0xffFF6B3D);
      case DamageType.ice:
        return Color(0xff3DA9FF);
      case DamageType.air:
        return Color(0xffD8F4FF);
      case DamageType.poison:
        return Color(0xff9BDB3B);
      case DamageType.holy:
        return Color(0xffFFF275);
      case DamageType.dark:
        return Color(0xff8E5CFF);
      default:
        return Colors.grey;
    }
  }
}
