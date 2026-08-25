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
// This is the revised scale (2026-08-25) — the first version just named
// whatever sizes were already scattered around; a live simulator pass
// across Town Square/Skill Tree/Quest Board/combat surfaced a real
// hierarchy inversion in that first-draft set (individual buttons reading
// louder than the section headers organizing them, the character's own
// name reading smaller than a menu button, one CTA left un-migrated at an
// oddly small size) and this scale corrects it, not just catalogs it:
// - `subheading`/`cardHeader` (18/16) merged into one `sectionHeader` (18)
//   — the character's name and a card's own section label do the same
//   job (introduce a block of content) and should carry the same weight.
// - `emphasis` (22) narrowed to true one-off standouts (a tier-divider
//   header) — it no longer covers ordinary menu buttons.
// - `sectionTitle` (20) widened to cover every full-width tappable
//   button label in this area (Town Location buttons, the Skill Tree
//   button) — previously those were inconsistent (22px, or a bespoke
//   un-migrated 14px), now every "tap this to go somewhere" button reads
//   at one consistent size.
//
// Extended (same day) with a parallel *regular*-weight track — while
// migrating the rest of the app beyond Town Square, 20px/22px/18px turned
// out to be just as common at regular weight (combat numbers, equipment
// item labels, toasts, the enemy info modal, Forge's rarity chips and
// cost readouts) as they are at bold. Rather than force that text onto
// the bold tiers above (which would visually embolden it) or leave it
// all as inline literals, `subtitle`/`label`/`detail` sit at the same
// three sizes as `emphasis`/`sectionTitle`/`sectionHeader` but regular —
// together with `banner`/`title` (already regular) that's a complete
// parallel ladder: 28/24/22/20/18 in both weights, matching how the app
// already mixes bold headers with regular numeric/detail readouts at the
// same visual size.
class QvTextStyles {
  QvTextStyles._();

  // 28px, regular — the largest headline: a destination's arrival-banner
  // name (TownVisitSheet), a zone's name on the Quest Board.
  static const TextStyle banner = TextStyle(fontSize: 28);

  // 24px, regular — a prominent standalone title one step down from
  // banner: empty-state copy ("Coming Soon"), a primary action button's
  // own label ("Begin Quest").
  static const TextStyle title = TextStyle(fontSize: 24);

  // 22px, bold — reserved for a genuine one-off standout on its own
  // screen, not shared with ordinary menu buttons: a tier-divider header.
  static const TextStyle emphasis = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

  // 22px, regular — the regular-weight sibling of `emphasis`: a menu-item
  // button label that isn't meant to read as bold/shouty (Forge's slot
  // picker buttons), a secondary title-weight line.
  static const TextStyle subtitle = TextStyle(fontSize: 22);

  // 20px, bold — a page/sheet-level section header ("Skill Points: N", a
  // skill's name in its own detail panel) *and* any full-width tappable
  // menu-button label (Town Location buttons, the Skill Tree button) — one
  // consistent size for "this text is a button you can press to go
  // somewhere," regardless of which card it lives in.
  static const TextStyle sectionTitle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  // 20px, regular — the regular-weight sibling of `sectionTitle`: a short
  // label or numeric readout (a rarity name, "Level N", a gold amount, a
  // combat damage number) rather than a header or a button.
  static const TextStyle label = TextStyle(fontSize: 20);

  // 18px, bold — introduces a block of content: the character's name on
  // the stats card, or a list-item card's own section label (Equipment,
  // Skills, Weapon & Artifact, Potions on Town Square). Both are doing the
  // same job at the same level of the page's hierarchy, so they share one
  // size rather than being split across two adjacent-but-different tiers.
  static const TextStyle sectionHeader =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  // 18px, regular — the regular-weight sibling of `sectionHeader`: dense
  // info-panel text (a stat modifier line, a cost breakdown row) that
  // needs to be a size up from `body` without reading as a heading.
  static const TextStyle detail = TextStyle(fontSize: 18);

  // 14px, regular — descriptive/paragraph text and secondary subtitles.
  static const TextStyle body = TextStyle(fontSize: 14);

  // 13px, regular — small print: stat values, secondary detail lines.
  static const TextStyle caption = TextStyle(fontSize: 13);
}
