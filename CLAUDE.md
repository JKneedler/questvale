# Questvale (Flutter app)

Flutter implementation of **Questvale**, a gamified to-do list / habit tracker where completing real-world tasks generates in-game Action Points spent on RPG-style dungeon-crawl progression. GitHub: `JKneedler/questvale`.

**Game design lives in a separate Obsidian vault**, not in this repo: `~/Documents/Obsidian Vaults/Questvale`. That vault is the single source of truth for both game design decisions (mechanics, balance, content, UI/UX) and programming/framework/architecture decisions for this codebase — see the `capture-decision` skill below. Consult the vault (especially `03_Game_Systems/` for mechanics and `05_Development/Architecture/App Structure.md` for prior architecture decisions) before making design-affecting implementation choices.

## Architecture

- **State management:** `flutter_bloc` (Cubit pattern), organized by feature under `lib/cubits/` — `home/`, `character_tab/`, `todo_tab/`, `world_tab/`, `settings/`. Each feature typically has its own cubit + state + page, with further nesting for sub-flows (e.g. `world_tab/town/forging/`).
- **Data layer:** `lib/data/`
  - `models/` — plain Dart data models (Character, Equipment, Enemy, Quest, Encounter, Todo, StatModifier, etc.)
  - `repositories/` — one per model area, wrapping `sqflite` queries (CharacterRepository, EquipmentRepository, QuestRepository, EncounterRepository, EnemyRepository, StatModifiersRepository, TodoRepository)
  - `providers/game_data.dart` + `game_data_models/` — static/reference game data (as opposed to persisted player data)
  - `skills/` — skill implementations as Dart classes extending `base_active_skill.dart` / `base_passive_skill.dart`
  - `questvale_db.dart` — local SQLite database setup (`sqflite`), creates tables and seeds a default character on first run
- **Services:** `lib/services/` — `combat_service.dart`, `equipment_service.dart`, `quest_service.dart`, `skill_service.dart` — business logic that sits between cubits and repositories
- **Widgets:** `lib/widgets/` — shared UI components, prefixed `qv_` (`qv_button.dart`, `qv_card_border.dart`, `qv_equipment_item.dart`, etc.), matching the vault's pixel-art design system
- **DB access:** `Database` instance created in `main.dart` and provided app-wide via `package:provider`

## Key dependencies (see `pubspec.yaml`)
`flutter_bloc`, `sqflite`, `provider`, `equatable`, `uuid`, `flutter_slidable`, `google_fonts`, `material_symbols_icons`, `intl`, `collection`

## Working mode

Design and architecture decisions made while working in this repo should be captured in the vault, not left only in this repo's commit history or chat — use the **`capture-decision`** skill (mirrored here at `.claude/skills/capture-decision/`; canonical copy lives in the vault). It always writes to and commits in the vault (`~/Documents/Obsidian Vaults/Questvale`), regardless of this repo's own git state, so the two repos' histories stay independent. Game design → vault's `03_Game_Systems/` etc.; programming/framework/architecture decisions (state management patterns, package choices, data layer conventions, testing approach) → vault's `05_Development/`.

This repo's own git history should stay about the code itself — normal commits for actual implementation work, following whatever branch/PR conventions are already in use (see `git log` and GitHub for current patterns).
