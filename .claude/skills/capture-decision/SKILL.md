---
name: capture-decision
description: Capture a confirmed Questvale decision — game design OR programming/framework/architecture — into the Questvale Obsidian vault, which is the single decision store for both. Edits the relevant note in place and commits the change to the vault's git repo with a descriptive message. Trigger whenever a conversation (in the vault, or in the ~/Documents/Flutter/questvale code repo) reaches a settled decision — a new mechanic, a changed number, a resolved open question, a filled-in stub, a chosen package/pattern/architecture approach — that should live in the docs rather than only in chat. Also trigger on explicit requests like "save that", "capture that decision", or "log that".
---

# Capture Decision

Turns a decision reached in conversation into a durable, in-place vault edit plus a git commit. This is the mechanism that makes the vault (`~/Documents/Obsidian Vaults/Questvale`) the single source of truth for Questvale — both its game design and its Flutter implementation choices — instead of chat history.

**This skill always targets the vault, regardless of which repo the current session's working directory is.** If invoked from within `~/Documents/Flutter/questvale` (this skill is mirrored there too — keep both copies in sync if the workflow changes), use the vault's absolute path for every file operation, and run git commands as `git -C "/Users/jaredkneedler/Documents/Obsidian Vaults/Questvale" <cmd>` rather than relying on cwd.

## Two decision types, two homes

- **Game design decisions** (mechanics, balance, content, UI/UX) → `03_Game_Systems/`, `04_Game_Content/`, `02_Design_System/`, or `Equipment Modifiers.md`.
- **Programming/framework/architecture decisions** (state management patterns, package choices, data layer structure, testing approach, folder conventions, etc.) → `05_Development/` (primarily `05_Development/Architecture/App Structure.md` for now; split into sibling notes under `05_Development/` once a distinct concern — e.g. "Data Layer", "Dependencies" — accumulates enough content to warrant its own note, mirroring how the game-system stubs work).

## When to fire

- Automatically, the moment a point is actually **settled** — not for exploratory back-and-forth, brainstorming lists of options, or "maybe" statements. If it's still being weighed, don't capture it yet.
- On explicit request ("save that", "capture that decision", "/capture-decision", etc.) even mid-discussion.

When you fire automatically, say one short line naming what you're saving and where *before* writing (e.g. "Noted — saving Rogue's resource as Focus to `Skills/Overview.md`." or "Noted — saving the Cubit-per-feature convention to `05_Development/Architecture/App Structure.md`."), then proceed straight to writing and committing. Don't wait for a go-ahead — git history is the safety net, not a confirmation step.

## Steps

1. **Restate the decision in one precise sentence** (in your head, not necessarily aloud) — the exact number, name, or rule, and its scope. If the conversation left it ambiguous (e.g. "somewhere around 10%" with no agreed exact value, or "probably flutter_bloc but not sure"), that's not settled yet — don't capture, ask instead.

2. **Find the target note(s), in the vault.**
   - Prefer an existing note over creating a new one. For design: check `03_Game_Systems/` (mechanics/rules) and `04_Game_Content/` (specific instances — enemies, zones, items) first. For tech/framework: check `05_Development/` first.
   - A decision can touch more than one note (e.g. a class resource name shows up in `Skills/Overview.md` *and* `02_Design_System/Color Palette.md`). Update every note that states the affected fact, not just the most obvious one.
   - If nothing fits, use the known empty stub docs as the intended home rather than inventing a new file: `03_Game_Systems/Equipment/Overview.md`, `Forge.md`, `Stats & Modifiers.md`, `Gems/Gemforge.md`, `Skills/Overview.md`, `Buying & Selling/Overview.md`. Only create a genuinely new note if none of the above and no existing note is a reasonable fit — and if so, base its shape on `_templates/Base Note Template.md` and the nearest sibling note.

3. **Check for conflicts.** Grep the vault for other statements of the same fact (a stat, a name, a rule) before editing. If you find one that disagrees with the new decision, **stop and ask** which one is correct rather than picking silently — don't overwrite without confirming.

4. **Match the note's existing style** rather than imposing a generic format. Conventions seen across this vault:
   - Frontmatter block with `tags:` and often `status:` (`reference`, `in-progress`, etc.).
   - Emoji + Title Case section headers, sections separated by `---`.
   - Obsidian callouts: `> [!summary]`, `> [!note]`, `> [!tip]`, `> [!info]`, `> [!abstract]`, `> [!example]` — append `-` for a collapsed callout (`> [!note]-`).
   - Pipe tables for structured stats/comparisons.
   - A trailing `## Related` / `## Related Notes` section listing `[[wikilinks]]`.
   - If editing a note that already has content, mirror *that note's* voice and structure exactly. If filling an empty stub, borrow structure from the most complete sibling doc in the same folder (e.g. use `Gems/Overview.md` as the model when filling `Equipment/Overview.md`; use `05_Development/Architecture/App Structure.md`'s own conventions for other tech notes).
   - Add or update `[[wikilink]]` cross-references if the edit creates a new connection between notes. For tech decisions, reference specific code locations with plain code spans (e.g. `` `lib/cubits/character_tab/equipment/` ``) rather than wikilinks, since those aren't vault notes.
   - If you notice unrelated leftover template placeholders in a file you're touching anyway (e.g. a literal `updated: {{date}}`), fine to clean that up as part of the same edit — but don't go fix unrelated stubs you weren't asked about.

5. **Write the edit** with Edit (or Write, only for genuinely new notes) — using the vault's absolute path if the session's cwd is elsewhere.

6. **Commit it on its own, in the vault repo specifically.** Stage only the file(s) this decision touched — don't sweep in unrelated changes — and commit with a message describing *what was decided*, not just what file changed:
   ```
   git -C "/Users/jaredkneedler/Documents/Obsidian Vaults/Questvale" add "<file>" ["<file2>" ...]
   git -C "/Users/jaredkneedler/Documents/Obsidian Vaults/Questvale" commit -m "Set Rogue resource to Focus, regen on crit"
   ```
   One commit per decision keeps `git log` (in the vault repo) a readable decision history. **Never commit these vault-targeted changes into the Flutter repo's git history** — the two repos' histories stay independent even when this skill runs from within the Flutter repo.

7. **Confirm** back to the user in one line once done (file(s) touched + commit made), unless you already announced it in step 0/"When to fire" — don't repeat yourself.

## Guardrails

- Never commit exploratory ideas, open questions, or anything phrased tentatively.
- Never bundle multiple unrelated decisions into one commit.
- Never run destructive git operations (`reset --hard`, force-push, etc.) on this repo without explicit confirmation — same rule as any other git repo.
- If a decision would require creating a real new note (not one of the known stubs) or restructuring an existing one significantly, it's fine to just do it — this vault is low-stakes and fully versioned — but keep the same conflict-check discipline from step 3.
