import 'package:equatable/equatable.dart';

class NavState extends Equatable {
  final int tab;

  // Whether a bottom modal sheet that leaves the nav bar visible beneath it
  // (TownVisitSheet — see the Combat & Questing Redesign ticket) is
  // currently open. NavBar reads this to swap its own background to match
  // the sheet's, so the two read as one continuous surface rather than a
  // visible seam. Sheets that cover the nav bar entirely (AddTodo/EditTodo,
  // via useRootNavigator) have no reason to touch this — nothing of the nav
  // bar is visible underneath them to recolor.
  final bool modalSheetOpen;

  const NavState({required this.tab, this.modalSheetOpen = false});

  NavState copyWith({
    int? tab,
    bool? modalSheetOpen,
  }) {
    return NavState(
      tab: tab ?? this.tab,
      modalSheetOpen: modalSheetOpen ?? this.modalSheetOpen,
    );
  }

  @override
  List<Object?> get props => [tab, modalSheetOpen];
}
