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

  const NavState({required this.tab, this.showCombatNavBackground = false});

  NavState copyWith({
    int? tab,
    bool? showCombatNavBackground,
  }) {
    return NavState(
      tab: tab ?? this.tab,
      showCombatNavBackground:
          showCombatNavBackground ?? this.showCombatNavBackground,
    );
  }

  @override
  List<Object?> get props => [tab, showCombatNavBackground];
}
