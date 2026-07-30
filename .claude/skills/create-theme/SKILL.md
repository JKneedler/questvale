---
name: create-theme
description: Create a brand-new, additional Questvale theme — copies an existing theme's per-theme PNGs into a new images/ui/{category}/{themeId}/ folder, recolors the copies, generates the 4 pressed-state button variants, registers a new AppTheme entry in lib/helpers/constants.dart, and adds the required pubspec.yaml asset lines. The new theme becomes immediately selectable from the Settings theme picker. Trigger whenever the user wants to add a new theme option (as opposed to retuning an existing one in place — that's retheme-color's job).
---

# Create Theme

Adds a brand-new theme to Questvale's multi-theme system: a new named palette (Primary/Secondary/Surface/Surface Container, each with Main/Light/Dark) with its own PNG asset folder, registered so it shows up as another option in the Settings theme picker — without touching any existing theme's colors or assets.

This is the counterpart to the **`retheme-color`** skill: `retheme-color` retunes a *named existing* theme's colors in place; this skill produces a *new, additional* theme by copying an existing theme's assets and recoloring the copies. Both are built on the same `.claude/skills/retheme-color/retheme_color.py` script (reused here as-is, no script changes needed).

**The 12 theme-dependent files**, present in every theme's folder (confirmed via the 2026-07 multi-theme migration — everything else under `images/ui/` is shared and theme-independent, untouched by this skill):
- `buttons/{themeId}/`: `button-primary.png`, `button-primary-flat.png`, `button-secondary.png`, `button-surface.png`, `button-surface-container.png`
- `borders/{themeId}/`: `border-primary.png`, `border-primary-mini.png`, `border-surface-mini.png`, `border-surface-container-mini.png`, `border-primary-metal-edge.png` (a hybrid — also contains Metal Corner's own colors, which must NOT change; only its Primary-derived pixels do)
- `backgrounds/{themeId}/`: `background-secondary.png`, `background-surface.png`

Border stays a fixed universal `#000000` in every theme, including the new one — never part of the color set being generated here.

**Plus 4 pressed-state button variants** (added 2026-07, alongside the tap-animation feature in `lib/widgets/qv_button.dart`): `buttons/{themeId}/button-primary-pressed.png`, `button-secondary-pressed.png`, `button-surface-pressed.png`, `button-surface-container-pressed.png` — one per theme-dependent button color that `QvButton` actually renders a pressed state for (`button-primary-flat.png` has no pressed sibling; borders/backgrounds don't either). Each is generated from that role's own already-recolored button PNG with its Light and Dark Accent pixel values swapped — same technique, reusing `retheme_color.py apply`, just with a same-file `--pair light:dark --pair dark:light` swap instead of an old→new remap. `QvButton.pressedAssetPath` (`lib/widgets/qv_button.dart`) expects these to exist for every registered theme, so don't skip this for a new theme.

## Steps

1. **Ask for the new theme's id (kebab-case, e.g. `arctic-blue`) and display name (e.g. "Arctic Blue"), plus the 4 new Main colors** (Primary/Secondary/Surface/Surface Container). Confirm the id isn't already a key in `lib/helpers/constants.dart`'s `APP_THEMES` map. If Light/Dark accents weren't given explicitly, run `.claude/skills/retheme-color/retheme_color.py derive --old-main --old-light --old-dark --new-main` per role (using the *source* theme's — see step 2 — current values as "old") as a starting suggestion, but always confirm before finalizing: the HSL-offset method can produce tinted, non-neutral results when shifting between a saturated and a desaturated/neutral hue (this happened for real going from the original warm palette to `charcoal-gold`'s cooler grays) — offer a hand-computed lightness-stepped alternative (same hue/saturation as the new Main, just lighter/darker) if the derived suggestion looks off.

2. **Pick a source theme to copy from** — default `charcoal-gold` unless the user names a different existing theme. Read its current 12 values from `APP_THEMES` fresh (not memory).

3. **Copy the source theme's asset files** (not move — the source theme must stay untouched) into new folders: `images/ui/buttons/{newId}/`, `images/ui/borders/{newId}/`, `images/ui/backgrounds/{newId}/`, one file at a time (`cp`, not `git mv`), then `git add` the new files.

4. **Dry-run, then apply, the color substitution** on the copies only: for each of the 4 roles, `retheme_color.py apply --pair <sourceMain>:<newMain> --pair <sourceLight>:<newLight> --pair <sourceDark>:<newDark> --files <that role's files under the NEW theme's folders>` (same per-role file grouping `retheme-color`'s own SKILL.md documents — Primary's group includes the hybrid `border-primary-metal-edge.png`). Always `--files` scoped to the new folder, never `--dir` — the source theme's files must never be touched. Show the per-file pixel-count summary; a file returning 0 changed pixels is a red flag — investigate before proceeding, never touch the source theme to "fix" it.

5. **Generate the 4 pressed-state button variants**, now that the new theme's own button PNGs carry their final recolored Light/Dark pixels: for each of `button-primary.png`, `button-secondary.png`, `button-surface.png`, `button-surface-container.png` in the new theme's folder, `cp` it to a `-pressed.png` sibling, then dry-run and apply `retheme_color.py apply --pair <newLight>:<newDark> --pair <newDark>:<newLight> --files images/ui/buttons/{newId}/button-<role>-pressed.png` (that role's own confirmed new Light/Dark values from step 4 — a same-file swap, not a remap from another theme). Sanity-check each result the same way this was verified originally: the pressed file's Main/Border/Transparent/Shadow pixel counts must exactly match the un-pressed original, with only the Light and Dark counts swapped — if they don't, investigate before moving on rather than assuming it's fine.

6. **Register the new theme** in `lib/helpers/constants.dart`'s `APP_THEMES` map — a new `AppTheme(id: ..., displayName: ..., ...)` entry with all 12 values: each role's Main plus the Light/Dark it actually confirmed and baked into the PNGs in step 4, not just the 4 Mains asked for in step 1. **This alone is what makes it selectable from Settings** — `ThemePicker` (`lib/cubits/settings/settings_page.dart`) iterates `APP_THEMES.values` directly (`for (final theme in APP_THEMES.values) ...`), not a hardcoded list, so no separate "add it to the dropdown" step exists or is needed. Still, `grep -n "APP_THEMES.values" lib/cubits/settings/settings_page.dart` once to confirm that's still true before assuming it — if `ThemePicker` was ever refactored to a hardcoded/filtered list, this step would need updating too.

7. **Add 3 new `pubspec.yaml` asset lines** for the new theme's folders (`images/ui/buttons/{newId}/`, `images/ui/borders/{newId}/`, `images/ui/backgrounds/{newId}/`) — Flutter asset directories aren't recursive, so each per-theme folder needs its own explicit line, same as every existing theme/category folder already does. The 4 pressed-state files from step 5 live in the same `buttons/{newId}/` folder, so they're already covered — no extra line needed for them.

8. **Update the vault** (`02_Design_System/Color Palette.md` and/or `Theming.md` — add the new theme alongside any existing ones, following whatever structure is already there for `charcoal-gold`; if this is the first *additional* theme, it's fine to introduce a small "Themes" table since one didn't exist before), commit in the **vault's own repo** — never this repo's git history (same rule `capture-decision` follows).

9. **Print a final summary**: new theme id/display name, source theme copied from, Dart file(s) touched, PNG(s) generated with pixel counts (including the 4 pressed variants), pubspec.yaml lines added, vault commit hash. Confirm the new theme is selectable **immediately** from Settings (per step 6, already verified — not just a hopeful reminder) — no restart needed, since `ThemePicker` and `ThemeCubit` both read `APP_THEMES` live. Suggest actually selecting it in the simulator to eyeball the result, since a wrong hex assumption shows up visually, not as a compile error.

## Guardrails

- Never modify the *source* theme's colors or assets — this skill only ever writes to the brand-new theme's folder and its own `AppTheme` entry.
- Never touch Border — every theme, including the new one, uses the fixed universal `#000000`; don't generate or register a per-theme border color.
- Never scan or copy `images/ui/icons/` or any other shared, theme-independent asset (rarity buttons/borders, skill borders, health border, checkboxes, nav) — only the 12 theme-dependent files listed above.
- Never skip the 4 pressed-state button variants (step 5) — `QvButton.pressedAssetPath` assumes every registered theme has all 4, and a missing file would throw an asset-loading error the first time that button color is pressed in that theme, not just look wrong.
- Always dry-run the substitution pass and show the summary before writing for real.
- Always confirm the derived or hand-computed Light/Dark accents with the user before baking them into the new theme's assets and `AppTheme` entry — never apply a suggestion silently.
- Vault commits stay in the vault's own repo — never commit vault-targeted changes into this repo's git history.
- If a copied file comes back with zero substituted pixels during the real (non-dry-run) apply, stop and investigate rather than treating it as done — a silent no-op usually means a wrong hex assumption, not a "nothing to do here."
