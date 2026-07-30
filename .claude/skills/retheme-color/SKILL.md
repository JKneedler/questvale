---
name: retheme-color
description: Change one of Questvale's four core theme colors (Primary, Secondary, Surface, Surface Container) at will — updates gameScheme in lib/main.dart, any stray hardcoded Color() literals matching the old hex, and pixel-by-pixel remaps every images/ui/ PNG (excluding icons/) that uses that color as its Main/Light Accent/Dark Accent. Trigger whenever the user wants to retune, swap, or experiment with Primary/Secondary/Surface/Surface Container's color.
---

# Retheme Color

Changes one of the four core theme colors (Primary, Secondary, Surface, Surface Container) everywhere it's expressed — in code and in the pixel-art asset tree — so the user can freely retune the palette without hunting down every place a color is baked in. The user has said they aren't fully committed to the current colors, so this needs to be a safe, repeatable, low-effort operation, not a one-off manual edit.

**Surface Container** (`gameScheme.surfaceContainer`) was promoted to this skill's scope in 2026-07 — it was already independently hardcoded in `gameScheme` before that, coincidentally equal to Metal Corner's Main (`#cbcbcb`), but had no vault documentation, no Light/Dark Accent shades of its own, and no button/border assets. It now has both (`button-surface-container.png`, `border-surface-container-mini.png`) and is meant to be retuned fully independently of Metal Corner going forward — treat any future coincidental match with Metal Corner (or anything else) the same as step 3's cross-field check, not as a reason to couple them.

**Backing script:** `.claude/skills/retheme-color/retheme_color.py` (Pillow-based). Two modes:
- `derive --old-main --old-light --old-dark --new-main` (hex, no `#`) — prints suggested new Light/Dark Accent shades via an HSL lightness/saturation offset from the old Main, applied to the new Main's hue. Use this when the user gives only a new Main color and hasn't specified accent shades themselves.
- `apply --pair OLDHEX:NEWHEX [--pair ...] (--dir DIR | --files a.png,b.png,...) [--dry-run] [--include-icons]` — substitutes exact RGB pixel values, skipping transparent (`0,0,0,0`) and drop-shadow (`0,0,0,52`) pixels. `--dir` recursively scans (excluding `images/ui/icons/` by default); `--files` takes an explicit comma-separated list. Always dry-run first and inspect the per-file pixel-count summary before writing for real.

Border is intentionally **not** part of this skill's scope — it was decoupled to a fixed `#000000` in 2026-07 specifically so a Primary/Secondary/Surface change never ripples into the border ring. Don't reintroduce that coupling; if the user wants Border to track a color again, that's a separate, explicit decision (see vault `02_Design_System/Theming.md`).

## Steps

1. **Confirm which role and the new Main hex.** One of Primary/Secondary/Surface/Surface Container, plus the new Main color. If the user hasn't given explicit new Light/Dark Accent values, run `derive` with the role's current Main/Light/Dark (from `lib/main.dart`, not memory — read it fresh) and the new Main, and present the suggested accents for confirmation before proceeding — don't just apply them silently.

2. **Read current values fresh from `lib/main.dart`'s `gameScheme`** (not the vault, not memory — code is the runtime source of truth) and cross-check against the vault's `02_Design_System/Color Palette.md` row for that role. If they disagree, stop and ask which is correct rather than picking one.

3. **Cross-field duplication check.** Grep `gameScheme` in `lib/main.dart` for every field, and check whether any other field (e.g. `onSecondary`, `onSurface`) happens to exactly equal one of the *old* hex values about to change. These coincidental matches aren't guaranteed to stay meaningful after the color changes — report any matches found and ask before touching them; never cascade a change into a field the user didn't ask about.

4. **Grep `lib/` for stray hardcoded color literals** matching the old hex(es) — `Color(0x...)` or `Color.fromARGB(...)` outside of `gameScheme` itself. As of 2026-07 there are none (the known instance in `equipment_gear_up_page.dart` was fixed and given a home as `PRIMARY_DARK_ACCENT_COLOR` in `lib/helpers/constants.dart`), but re-check live every run since this can drift again as new code is added.

5. **Dry-run the asset pass.** Run `retheme_color.py apply --pair OLDMAIN:NEWMAIN --pair OLDLIGHT:NEWLIGHT --pair OLDDARK:NEWDARK --dir images/ui --dry-run` (excludes `icons/` automatically). Show the user the per-file changed-pixel-count summary. A file expected to use this color family that comes back with 0 changed pixels is a red flag — investigate before proceeding (likely means the hex assumption was wrong for that file, e.g. the Surface family's asset-specific quirks). Confirm with the user, then re-run without `--dry-run`.

6. **Update `lib/main.dart`'s `gameScheme`** (the role's `primary`/`secondary`/`surface`/`surfaceContainer` field and its paired `on*` field if it's meant to track Main — note Surface Container has no dedicated `on*` field of its own today) plus any confirmed cross-field duplicates from step 3, and any confirmed stray literals from step 4.

7. **Update the vault**, in the vault's own repo (never this repo's git history — same rule `capture-decision` follows):
   - `02_Design_System/Color Palette.md`'s row for this role (Light Accent/Main/Dark Accent hex columns).
   - `02_Design_System/Theming.md`'s "Colors → Code" table and, if the change affects anything described in "Asset Color Roles", that section too.
   - Commit with a message describing what changed (e.g. "Retune Primary from tan to teal"), same convention as `capture-decision`.

8. **Print a final summary**: Dart file(s) touched, PNG(s) touched with pixel counts, vault commit hash. Remind the user to run `flutter analyze` and eyeball the result in the simulator — a missed asset or wrong hex assumption shows up as a visual mismatch, not a compile error.

## Guardrails

- Never touch transparent (`0,0,0,0`) or drop-shadow (`0,0,0,52`) pixels — `retheme_color.py` already skips these, don't work around it.
- Never scan or edit `images/ui/icons/` — out of scope for this skill.
- Never touch Border — it's a fixed `#000000` independent of all three theme colors; don't reintroduce the coupling that was deliberately removed.
- Never cascade a color change into another `gameScheme` field or a stray literal without explicit confirmation, even on an exact hex match — coincidence isn't intent.
- Always dry-run the PNG pass and show the summary before writing for real.
- Vault commits stay in the vault's own repo — never commit vault-targeted changes into this repo's git history.
- If a file expected to contain the old color comes back with zero substituted pixels during the real (non-dry-run) apply, stop and investigate rather than treating it as done — a silent no-op usually means a wrong hex assumption, not a "nothing to do here."
