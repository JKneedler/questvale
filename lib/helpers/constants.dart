import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

const DIFFICULTY_ICON = Symbols.trophy;
const PRIORITY_ICON = Symbols.flag_2;
const CALENDAR_ICON = Symbols.calendar_clock;

const GRAY_FILTER_MATRIX = <double>[
  // R         G         B         A  Bias
  0.2126, 0.7152, 0.0722, 0, 0, // R'
  0.2126, 0.7152, 0.0722, 0, 0, // G'
  0.2126, 0.7152, 0.0722, 0, 0, // B'
  0, 0, 0, 1, 0, // A'
];

const ENCOUNTER_FIRST_PLAY_DELAY = 1000; // 1 second

const HEALTH_COLOR = Color(0xffFF4646);
const MANA_COLOR = Color(0xff4679FF);
const RAGE_COLOR = Color(0xffFF6231);
const FOCUS_COLOR = Color(0xff5CE1A6);
const EXP_COLOR = Color(0xffFFD966);

const GOLD_COLOR = Color(0xffFFD966);
const ACTION_POINTS_COLOR = Colors.white;
const SKILL_POINTS_COLOR = Color(0xffFFD966);

// 9-slice (centerSlice) border/button asset families. All source PNGs are
// 64x64 at scale 1.0. A widget rendered smaller than a family's min size
// makes Flutter's centerSlice math collapse to zero and throws "centerSlice
// was used with a BoxFit that does not guarantee that the image is fully
// visible" — regardless of BoxFit. Keep each *_SLICE in sync with its PNG's
// actual border inset if the art changes.
//
// Each *_MIN_SIZE must be STRICTLY GREATER than its slice's border inset
// (inputSize - centerSlice.size), not merely >=. Flutter computes
// outputSize = widgetSize - sliceBorder and requires outputSize > 0; at
// exactly widgetSize == sliceBorder, outputSize is 0 and the same assertion
// still fires. The values below add a few px of headroom past the bare
// mathematical floor so the stretchy middle isn't zero-width either.
const STANDARD_BORDER_SLICE = Rect.fromLTWH(16, 16, 32, 32);
const STANDARD_BORDER_MIN_SIZE = Size(36, 36);

const METAL_CORNER_BORDER_SLICE = Rect.fromLTWH(28, 28, 8, 8);
const METAL_CORNER_BORDER_MIN_SIZE = Size(60, 60);

const HEALTH_BORDER_SLICE = Rect.fromLTWH(4, 4, 56, 56);
const HEALTH_BORDER_MIN_SIZE = Size(12, 12);

// Combat
const BASE_HEALTH = 100;
const BASE_HEALTH_PER_LEVEL = 10;
const BASE_RESOURCE_REGEN = 10;
const BASE_RESOURCE_REGEN_PER_LEVEL = 1;
const BASE_CRIT_CHANCE = .05;
const BASE_CRIT_DAMAGE_MULTIPLIER = 2;
const BASE_STATUS_EFFECT_CHANCE = .05;
