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

// A theme's full color set — Main, Light Accent, and Dark Accent for each
// of the 4 core roles (Primary/Secondary/Surface/Surface Container). These
// 12 values are the single source of truth: whatever shade a theming skill
// bakes into a theme's PNGs is recorded here too, so it stays readable from
// code (e.g. AppTheme.primaryDark) without reverse-engineering it from an
// image. Border is deliberately NOT part of this — it's a fixed universal
// #000000 across every theme (see vault Theming.md), not theme-dependent.
class AppTheme {
  final String id;
  final String displayName;
  final Color primaryMain;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondaryMain;
  final Color secondaryLight;
  final Color secondaryDark;
  final Color surfaceMain;
  final Color surfaceLight;
  final Color surfaceDark;
  final Color surfaceContainerMain;
  final Color surfaceContainerLight;
  final Color surfaceContainerDark;

  const AppTheme({
    required this.id,
    required this.displayName,
    required this.primaryMain,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondaryMain,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.surfaceMain,
    required this.surfaceLight,
    required this.surfaceDark,
    required this.surfaceContainerMain,
    required this.surfaceContainerLight,
    required this.surfaceContainerDark,
  });

  // onPrimary/onSecondary/onSurface each deliberately track another role's
  // tone for contrast (established in the 2026-07 retheme) rather than
  // being independent inputs: onPrimary uses Surface's Main, onSecondary
  // uses Primary's Main, onSurface uses Primary's Light Accent. The
  // remaining fields are still-unnamed Material placeholder grays, not
  // theme-dependent (see Theming.md).
  ColorScheme get colorScheme => ColorScheme(
        brightness: Brightness.dark,
        primary: primaryMain,
        onPrimary: surfaceMain,
        secondary: secondaryMain,
        onSecondary: primaryMain,
        error: const Color(0xffd83030),
        onError: const Color(0xffeeeeee),
        surface: surfaceMain,
        onSurface: primaryLight,
        primaryContainer: const Color(0xff222222),
        surfaceContainerHigh: const Color(0xff383838),
        surfaceContainer: surfaceContainerMain,
        surfaceContainerLow: const Color(0xff292929),
        surfaceContainerLowest: const Color(0xff181818),
        onPrimaryContainer: const Color.fromARGB(255, 24, 24, 24),
        onSecondaryContainer: const Color(0xffa7a7a7),
        onSurfaceVariant: const Color(0xff313131),
        onPrimaryFixedVariant: const Color.fromARGB(255, 75, 75, 75),
      );
}

const Map<String, AppTheme> APP_THEMES = {
  'charcoal-gold': AppTheme(
    id: 'charcoal-gold',
    displayName: 'Charcoal & Gold',
    primaryMain: Color(0xffe8c468),
    primaryLight: Color(0xffffe99c),
    primaryDark: Color(0xffdaae3c),
    secondaryMain: Color(0xff3a3a3e),
    secondaryLight: Color(0xff707078),
    secondaryDark: Color(0xff1c1c1e),
    surfaceMain: Color(0xff1b1b1e),
    surfaceLight: Color(0xff505059),
    surfaceDark: Color(0xff0f0f11),
    surfaceContainerMain: Color(0xff3c3c44),
    surfaceContainerLight: Color(0xff717180),
    surfaceContainerDark: Color(0xff1f1f23),
  ),
  'sunrise-peach': AppTheme(
    id: 'sunrise-peach',
    displayName: 'Sunrise Peach',
    primaryMain: Color(0xffff9066),
    primaryLight: Color(0xffffc2a7),
    primaryDark: Color(0xfff96932),
    secondaryMain: Color(0xff4a3b45),
    secondaryLight: Color(0xff886d7f),
    secondaryDark: Color(0xff281f25),
    surfaceMain: Color(0xfffaf3ee),
    surfaceLight: Color(0xffffffff),
    surfaceDark: Color(0xffe9c9b3),
    surfaceContainerMain: Color(0xfffefefe),
    surfaceContainerLight: Color(0xffffffff),
    surfaceContainerDark: Color(0xffdddddd),
  ),
};

const String DEFAULT_THEME_ID = 'charcoal-gold';

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
