import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/nav_cubit.dart';

/// Shared entry point for every bottom sheet that should leave the bottom
/// nav bar visible beneath it (as opposed to AddTodo/EditTodo's
/// useRootNavigator, full-coverage sheets) — see the Combat & Questing
/// Redesign ticket. Deliberately *not* useRootNavigator (pushes onto the
/// nearest Navigator instead, whose overlay stops above the nav bar rather
/// than covering it) and toggles NavCubit.setModalSheetOpen around the
/// sheet's lifetime so NavBar can recolor itself to match. TownVisitSheet
/// and QvPickerSheet both route through this instead of duplicating the
/// mechanics.
Future<T?> showNavAwareModalSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) async {
  final navCubit = context.read<NavCubit>();
  navCubit.setModalSheetOpen(true);
  try {
    return await showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      builder: builder,
    );
  } finally {
    // Covers every dismissal path (close button, tap-outside, swipe-down,
    // a caller's own Navigator.pop on success) since they all resolve the
    // same Future.
    navCubit.setModalSheetOpen(false);
  }
}
