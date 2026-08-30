import 'package:flutter/material.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';
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

// Was ButtonColor.getColor(Rarity) on qv_button.dart itself — moved here
// (app-side) as part of the jk_pixel_ui extraction, since ButtonColor is
// now a fully generic library enum with no knowledge of Questvale's Rarity.
ButtonColor rarityButtonColor(Rarity rarity) {
  switch (rarity) {
    case Rarity.common:
      return ButtonColor.common;
    case Rarity.uncommon:
      return ButtonColor.uncommon;
    case Rarity.rare:
      return ButtonColor.rare;
    case Rarity.epic:
      return ButtonColor.epic;
    case Rarity.legendary:
      return ButtonColor.legendary;
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

// See the vault's Status Effects note. burn/slow/shield are implemented
// end-to-end (Skill System Foundations subtasks 3–4) — freeze/weakness
// exist here so the model/enum shape doesn't need revisiting when they're
// built later, per subtask 3's "model should support them generically"
// scope note. shield is appended last (not from the vault's Status Effects
// note, which predates it) rather than inserted alongside freeze/weakness,
// so no already-persisted StatusEffectInstance/ScheduledTimer row's
// `effectType.index` is reinterpreted.
enum StatusEffectType {
  burn,
  slow,
  freeze,
  weakness,
  shield;

  // Whether this effect ticks on its own recurring ScheduledTimer
  // (statusEffectTick — deals periodic damage) vs. just sitting inert until
  // a one-shot statusEffectExpiry timer removes it (every other effect so
  // far — a rate modifier, a stat modifier, or a shield, not a DoT).
  bool get ticks => this == StatusEffectType.burn;
}
