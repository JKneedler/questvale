import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';
import 'package:provider/provider.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/data/providers/game_data.dart';

/// Shared entry point for every bottom sheet reached from Town Square
/// (destination arrivals via TownVisitSheet, quick in-context pickers via
/// QvPickerSheet) — see the Combat & Questing Redesign ticket. Uses
/// useRootNavigator so the sheet's overlay spans the full screen and covers
/// the bottom nav bar, same as AddTodo/EditTodo (an earlier version of this
/// deliberately left the nav bar visible, just recolored to match — per
/// feedback, that's no longer wanted).
///
/// Pushing onto the root Navigator makes the new route a *sibling* of
/// HomePage's own route rather than a descendant, so it doesn't ambiently
/// see providers HomePage itself supplies internally — PlayerCubit and
/// GameData, both created inside HomePage.build (see home_page.dart), sit
/// below the root Navigator's route content, not above it. Captured here
/// from the real caller's context (still nested normally inside that
/// subtree) and re-provided by value around whatever the caller's builder
/// returns, so every sheet's content keeps ambient access without each
/// call site having to repeat this. (Database/ThemeCubit are provided
/// above MaterialApp in main.dart, so they're unaffected regardless of
/// which Navigator a route lands on. TownVisitSheet.showModal separately
/// re-provides WorldCubit for the same reason, one level further down —
/// see its own doc comment.)
Future<T?> showNavAwareModalSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  final playerCubit = context.read<PlayerCubit>();
  final gameData = context.read<GameData>();
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    useRootNavigator: true,
    builder: (context) => Provider<GameData>.value(
      value: gameData,
      child: BlocProvider<PlayerCubit>.value(
        value: playerCubit,
        child: Builder(builder: builder),
      ),
    ),
  );
}

/// Questvale's own wiring for jk_pixel_ui's QvPickerSheet — that package's
/// widget only renders the shell (title + close button), since it has no
/// concept of this app's own navigation stack. This is the app-side
/// equivalent of the old QvPickerSheet.showModal (pre jk_pixel_ui
/// extraction): push it through showNavAwareModalSheet like every other
/// Town Square sheet.
Future<void> showQvPickerSheetModal(
  BuildContext context, {
  required String title,
  required Widget body,
}) {
  return showNavAwareModalSheet<void>(
    context,
    builder: (context) => QvPickerSheet(title: title, body: body),
  );
}
