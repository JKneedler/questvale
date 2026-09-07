import 'package:equatable/equatable.dart';

class NavState extends Equatable {
  final int tab;

  // True while QuestEncounterView (lib/cubits/world_tab/questing/
  // quest_encounter/quest_encounter_page.dart) is mounted — i.e. for the
  // whole quest-encounter flow, not just live combat — so NavBar can swap
  // its flat colorScheme.surface fill for the 9-sliced
  // surfaceNoTopNoBottom texture, continuing QuestVitalsAndSkillsCard's own
  // left/right border (a constant presence across that same flow) instead
  // of stopping dead where the card ends. Toggled by QuestEncounterView's
  // own State (initState/dispose), not read anywhere else.
  //
  // NOT sufficient on its own to decide whether to show that texture,
  // though: HomeView's IndexedStack keeps every tab mounted at once, so
  // switching tabs mid-quest never disposes QuestEncounterView (only
  // actually leaving the quest does) — this flag stays true globally the
  // whole time a quest is in progress, on every tab, not just World's.
  // HomeView's own NavBar call also checks tab == 0 before passing it
  // through as useCombatBackground.
  final bool showCombatNavBackground;

  // Bumped by NavCubit.requestCombatRefresh() — a lightweight cross-tab
  // signal for "an admin action changed something CombatCubit's live state
  // won't otherwise notice" (e.g. Settings' Reset all skill cooldowns).
  // NavCubit is the one cubit both SettingsPage and QuestEncounterView
  // already sit under (see HomeView's MultiBlocProvider), so it doubles as
  // the signal channel rather than inventing a dedicated event bus — a live
  // CombatCubit (only provided while a combat encounter is actually in
  // progress — see QuestEncounterView's build) isn't reachable directly
  // from Settings since IndexedStack keeps every tab's Navigator in its own
  // sibling subtree. Just a counter (not a bool) so two requests in a row
  // without an intervening rebuild still both register as changes.
  final int combatRefreshRequestId;

  const NavState({
    required this.tab,
    this.showCombatNavBackground = false,
    this.combatRefreshRequestId = 0,
  });

  NavState copyWith({
    int? tab,
    bool? showCombatNavBackground,
    int? combatRefreshRequestId,
  }) {
    return NavState(
      tab: tab ?? this.tab,
      showCombatNavBackground:
          showCombatNavBackground ?? this.showCombatNavBackground,
      combatRefreshRequestId:
          combatRefreshRequestId ?? this.combatRefreshRequestId,
    );
  }

  @override
  List<Object?> get props =>
      [tab, showCombatNavBackground, combatRefreshRequestId];
}
