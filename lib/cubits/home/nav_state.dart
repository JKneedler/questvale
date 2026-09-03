import 'package:equatable/equatable.dart';

class NavState extends Equatable {
  final int tab;

  // True while CombatPage (lib/cubits/world_tab/questing/combat/
  // combat_page.dart) is mounted — NavBar reads this to swap its flat
  // colorScheme.surface fill for the 9-sliced surfaceNoTopNoBottom texture,
  // so the nav bar's edge lines continue CombatVitalsAndSkillsCard's own
  // left/right border rather than stopping dead where the card ends.
  // Toggled by CombatPage's own State (initState/dispose), not read
  // anywhere else.
  final bool showCombatNavBackground;

  // Bumped by NavCubit.requestCombatRefresh() — a lightweight cross-tab
  // signal for "an admin action changed something CombatCubit's live state
  // won't otherwise notice" (e.g. Settings' Reset all skill cooldowns).
  // NavCubit is the one cubit both SettingsPage and CombatPage already sit
  // under (see HomeView's MultiBlocProvider), so it doubles as the signal
  // channel rather than inventing a dedicated event bus — CombatPage isn't
  // reachable directly from Settings since IndexedStack keeps every tab's
  // Navigator in its own sibling subtree. Just a counter (not a bool) so
  // two requests in a row without CombatPage rebuilding between them still
  // both register as changes.
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
  List<Object?> get props => [tab, showCombatNavBackground, combatRefreshRequestId];
}
