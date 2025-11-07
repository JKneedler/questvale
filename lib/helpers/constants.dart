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
