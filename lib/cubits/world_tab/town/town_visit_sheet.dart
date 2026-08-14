import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/home/nav_cubit.dart';
import 'package:questvale/cubits/world_tab/world_cubit.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_draggable_sheet.dart';
import 'package:questvale/widgets/qv_metal_corner_border.dart';

/// The shared "you have arrived" shell for every Town Square destination
/// (Quest Board, Shop, Guild Hall, Forge, Lab, Gemforge, Reliquary) — see
/// the Combat & Questing Redesign ticket. Replaces the old
/// TownCubit/TownLocation full-page slide-swap: Town Square is now the
/// permanent root and every destination opens as a tall modal sheet on top
/// of it, similar in spirit to how AddTodo/EditTodo sit on top of the Todo
/// Overview page — but unlike those, the bottom nav bar stays visible below
/// a town sheet rather than being covered (see showModal's own doc comment
/// on why that's a real, deliberate difference from AddTodoPage.showModal,
/// not an oversight). [iconPath] and [title] reuse the same art/label
/// already shown on the destination's TownLocationCard, so the banner reads
/// as a continuation of what was just tapped rather than a new,
/// disconnected screen.
class TownVisitSheet extends StatelessWidget {
  const TownVisitSheet({
    super.key,
    required this.title,
    required this.iconPath,
    required this.body,
    this.scrollableBody = false,
  });

  final String title;
  final String iconPath;
  final Widget body;

  /// See QvDraggableSheet.scrollableBody. Defaults false because every
  /// destination's own content today already manages its own internal
  /// layout/scrolling (built for a full-page Scaffold) — only a plain
  /// "Coming Soon" placeholder needs nothing fancier than the true default.
  final bool scrollableBody;

  static Future<void> showModal(
    BuildContext context, {
    required String title,
    required String iconPath,
    required Widget body,
    bool scrollableBody = false,
  }) async {
    // Deliberately *not* useRootNavigator (unlike AddTodoPage.showModal):
    // the bottom nav bar should stay visible/usable while a town location's
    // sheet is open, and pushing onto the World tab's own nested Navigator
    // (found by the default, nearest-ancestor lookup below) is what leaves
    // it that way — its overlay stops above HomeView's bottomNavigationBar
    // rather than covering it. That nested Navigator also sits below
    // HomePage's own GameData/PlayerCubit providers, so every destination's
    // content sees those two ambiently, same as before this ticket's
    // redesign.
    //
    // WorldCubit is a different story: it's provided *inside* WorldPage,
    // which is itself the route content this same Navigator is already
    // displaying — sibling routes on one Navigator don't share each other's
    // local providers, only ancestors *above* the Navigator do (that's why
    // GameData/PlayerCubit, provided in HomePage, are fine). So WorldCubit
    // needs the same by-value re-provide AddTodoPage.showModal would need
    // if it ever read something tab-route-local, captured here from the
    // real caller's context before the modal route is pushed — Quest
    // Board's "Begin Quest" reads it to flip WorldView over to the combat
    // page once a quest is created.
    final worldCubit = context.read<WorldCubit>();

    // NavCubit is provided in HomePage too (same reasoning as GameData/
    // PlayerCubit above), so this is read directly rather than hoisted —
    // it's only ever touched here, around the modal call, never from
    // inside the sheet's own subtree the way WorldCubit is.
    final navCubit = context.read<NavCubit>();
    navCubit.setModalSheetOpen(true);
    try {
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        builder: (context) => BlocProvider<WorldCubit>.value(
          value: worldCubit,
          child: TownVisitSheet(
            title: title,
            iconPath: iconPath,
            scrollableBody: scrollableBody,
            body: body,
          ),
        ),
      );
    } finally {
      // Covers every dismissal path (close button, tap-outside, swipe-down,
      // Begin Quest's own Navigator.pop) since they all resolve the same
      // Future — and the `finally` also catches a sheet dismissed by some
      // future caller throwing before ever showing, rather than leaving the
      // nav bar stuck on the sheet's color.
      navCubit.setModalSheetOpen(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return QvDraggableSheet(
      header: _TownVisitHeader(title: title, iconPath: iconPath),
      headerHeight: _TownVisitHeader.totalHeight,
      scrollableBody: scrollableBody,
      body: body,
    );
  }
}

class _TownVisitHeader extends StatelessWidget {
  const _TownVisitHeader({required this.title, required this.iconPath});

  final String title;
  final String iconPath;

  static const double _bannerHeight = 96;
  static const double _closeButtonSize = 36;
  static const double _bottomSpacing = 10;

  /// Total rendered height — QvDraggableSheet renders [_TownVisitHeader] as
  /// a fixed overlay above the scrollable/body region, so it needs to know
  /// exactly how much room to reserve.
  static const double totalHeight = _bannerHeight + _bottomSpacing;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: _bottomSpacing),
      child: SizedBox(
        height: _bannerHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            QvMetalCornerBorder(
              color: colorScheme.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: [
                  Image.asset(
                    iconPath,
                    width: 40,
                    height: 40,
                    filterQuality: FilterQuality.none,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.onSecondary,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -_closeButtonSize / 4,
              right: -_closeButtonSize / 4,
              child: QvButton(
                width: _closeButtonSize,
                height: _closeButtonSize,
                buttonColor: ButtonColor.surfaceContainer,
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Symbols.close,
                  weight: 700,
                  size: 18,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
