import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

const DIFFICULTY_ICON = Symbols.trophy;
const PRIORITY_ICON = Symbols.flag_2;
const CALENDAR_ICON = Symbols.calendar_clock;

const ENCOUNTER_FIRST_PLAY_DELAY = 1000; // 1 second

const HEALTH_COLOR = Color(0xffFF4646);
// Mana is fully retired for Mage (replaced by Motes below) and no other
// class has ever used it. Left defined in case a future class resource
// reuses the asset slot; QvBarResource.mana/the mana-*.png bar assets are
// otherwise dead as of the Mote rework.
const MANA_COLOR = Color(0xff4679FF);
const RAGE_COLOR = Color(0xffFF6231);
const FOCUS_COLOR = Color(0xff5CE1A6);
const FIRE_MOTE_COLOR = Color(0xffFF6B3D);
const ICE_MOTE_COLOR = Color(0xff3DA9FF);
// The Mote *system's* own color (label/count text on QvMoteDisplay) — kept
// distinct from the two per-element pip colors above, which stay Fire/Ice
// as normal. Reuses SkillButtonColor.arcanePurple's existing hex so the
// "arcane" identity stays a single source of truth rather than a second
// unrelated purple.
const MOTE_LABEL_COLOR = Color(0xFF6A2BAA);
const EXP_COLOR = Color(0xffFFD966);

const GOLD_COLOR = Color(0xffFFD966);
const ACTION_POINTS_COLOR = Colors.white;
const SKILL_POINTS_COLOR = Color(0xffFFD966);

// Todo difficulty/priority tier colors (see DifficultyLevel.color and
// PriorityLevel.color in lib/data/models/todo.dart).
const DIFFICULTY_TRIVIAL_COLOR = Colors.grey;
const DIFFICULTY_EASY_COLOR = Color(0xFFCD7F32); // Bronze
const DIFFICULTY_MEDIUM_COLOR = Color(0xFFC0C0C0); // Silver
const DIFFICULTY_HARD_COLOR = Color(0xFFFFD700); // Gold

const PRIORITY_NONE_COLOR = Colors.grey;
const PRIORITY_LOW_COLOR = Color(0xFF00BFFF); // Light Blue
const PRIORITY_MEDIUM_COLOR = Color(0xFFFFA500); // Orange
const PRIORITY_HIGH_COLOR = Color(0xFFDC143C); // Red

// Combat
// No flat BASE_HEALTH here — max HP's base term is per-class
// (CharacterClass.baseMaxHealth), read by PlayerCombatStats.maxHealth.
const BASE_HEALTH_PER_LEVEL = 10;
const BASE_RESOURCE_REGEN = 10;
const BASE_RESOURCE_REGEN_PER_LEVEL = 1;
const BASE_CRIT_CHANCE = .05;
const BASE_CRIT_DAMAGE_MULTIPLIER = 2;
const BASE_STATUS_EFFECT_CHANCE = .05;

// Mage's Mote resource: a shared cap across both elements (not per-element)
// — see the vault's Mage skill tree. A mote generated past this fizzles.
const MOTE_CAP = 3;

// AppTheme, APP_THEMES, DEFAULT_THEME_ID, the 9-slice geometry constants
// (STANDARD_BORDER_*, METAL_CORNER_BORDER_*, SMALL_BAR_*, MINI_BAR_*),
// GRAY_FILTER_MATRIX, and SCROLL_FADE_DISTANCE all moved to jk_pixel_ui's
// own lib/src/constants.dart as part of the UI-kit extraction — they're
// generic theming/geometry, not game data. Import
// package:jk_pixel_ui/jk_pixel_ui.dart wherever this file's code used to
// reach for one of those.
