import 'package:flutter/material.dart';
import 'package:questvale/helpers/constants.dart';

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

  String get borderAssetPath {
    switch (this) {
      case Rarity.common:
        return 'images/ui/borders/border-rarity-common-mini.png';
      case Rarity.uncommon:
        return 'images/ui/borders/border-rarity-uncommon-mini.png';
      case Rarity.rare:
        return 'images/ui/borders/border-rarity-rare-mini.png';
      case Rarity.epic:
        return 'images/ui/borders/border-rarity-epic-mini.png';
      case Rarity.legendary:
        return 'images/ui/borders/border-rarity-legendary-mini.png';
    }
  }

  String get buttonAssetPath {
    switch (this) {
      case Rarity.common:
        return 'images/ui/buttons/button-rarity-common.png';
      case Rarity.uncommon:
        return 'images/ui/buttons/button-rarity-uncommon.png';
      case Rarity.rare:
        return 'images/ui/buttons/button-rarity-rare.png';
      case Rarity.epic:
        return 'images/ui/buttons/button-rarity-epic.png';
      case Rarity.legendary:
        return 'images/ui/buttons/button-rarity-legendary.png';
    }
  }
}

// Mage's two mote colors — deliberately the same hexes as DamageType's
// fire/ice (the vault's Color Palette notes they're meant to match), kept
// as its own enum rather than reusing DamageType since a mote's element and
// a skill's damage type are conceptually distinct, even though every Tier 1
// skill happens to couple them 1:1.
enum MoteElement {
  fire,
  ice;

  Color get color {
    switch (this) {
      case MoteElement.fire:
        return FIRE_MOTE_COLOR;
      case MoteElement.ice:
        return ICE_MOTE_COLOR;
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

// See the vault's Status Effects note. Only burn/slow are implemented
// end-to-end this pass (Skill System Foundations subtask 3) — freeze/
// weakness exist here so the model/enum shape doesn't need revisiting when
// they're built later, per that subtask's "model should support them
// generically" scope note.
enum StatusEffectType {
  burn,
  slow,
  freeze,
  weakness;

  // Whether this effect ticks on its own recurring ScheduledTimer
  // (statusEffectTick — deals periodic damage) vs. just sitting inert until
  // a one-shot statusEffectExpiry timer removes it (every other effect so
  // far — a rate modifier or a stat modifier, not a DoT).
  bool get ticks => this == StatusEffectType.burn;
}
