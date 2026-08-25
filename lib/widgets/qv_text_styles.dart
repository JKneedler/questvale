import 'package:flutter/material.dart';

// Shared text-size/weight scale for the app's pixel-art UI — mirrors how
// ButtonColor/QvCardBorderType already centralize color/border choices
// instead of leaving them scattered as inline literals (see the vault's
// 05_Development notes for the decision this codifies). Color is
// deliberately NOT baked into these — every call site already varies color
// per-theme (colorScheme.onSurface, a resource color constant, etc.), so
// apply it with `.copyWith(color: ...)` at the call site, same as every
// existing usage already does. Font family isn't set here either —
// 'Pixel1' comes from the app-wide ThemeData in main.dart and is inherited
// automatically by any Text that doesn't override it.
//
// Named for the roles that were already recurring verbatim across Town
// Square/Quest Board/Skill Tree before this existed, not generic
// heading1/2/3 — each size below was pulled from ≥2 real call sites that
// already agreed on it, so introducing these named styles doesn't change
// any existing visual size, just gives the repeated values a name instead
// of a copy-pasted literal. Sizes some call sites use only once (10, 12,
// 15, 18-as-non-bold, etc.) are left as inline literals rather than forced
// onto the nearest tier — not every text needs a named token, only the
// ones that actually repeat.
class QvTextStyles {
  QvTextStyles._();

  // 28px, regular — the largest headline: a destination's arrival-banner
  // name (TownVisitSheet), a zone's name on the Quest Board.
  static const TextStyle banner = TextStyle(fontSize: 28);

  // 24px, regular — a prominent standalone title one step down from
  // banner: empty-state copy ("Coming Soon"), a primary action button's
  // own label ("Begin Quest").
  static const TextStyle title = TextStyle(fontSize: 24);

  // 22px, bold — a big, prominent label: a full-width menu button's own
  // text, a tier-divider header.
  static const TextStyle emphasis = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

  // 20px, bold — a page/sheet-level section header: "Skill Points: N", a
  // skill's name in its own detail panel.
  static const TextStyle sectionTitle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  // 18px, bold — a secondary-but-prominent heading: the character's name
  // on the stats card.
  static const TextStyle subheading =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  // 16px, bold — the repeated "list-item card" section header (Equipment,
  // Skills, Weapon & Artifact, Potions, etc. on Town Square).
  static const TextStyle cardHeader =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  // 14px, regular — descriptive/paragraph text and secondary subtitles.
  static const TextStyle body = TextStyle(fontSize: 14);

  // 13px, regular — small print: stat values, secondary detail lines.
  static const TextStyle caption = TextStyle(fontSize: 13);
}
