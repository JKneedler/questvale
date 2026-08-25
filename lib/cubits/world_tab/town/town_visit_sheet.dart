import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/home/nav_aware_modal_sheet.dart';
import 'package:questvale/cubits/world_tab/world_cubit.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_draggable_sheet.dart';
import 'package:questvale/widgets/qv_metal_corner_border.dart';
import 'package:questvale/widgets/qv_text_styles.dart';

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
/// already shown on the destination's row in Town Square's list, so the
/// banner reads as a continuation of what was just tapped rather than a
/// new, disconnected screen.
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
    // WorldCubit is provided *inside* WorldPage, which is itself the route
    // content the nav-aware Navigator (see showNavAwareModalSheet) is
    // already displaying — sibling routes on one Navigator don't share
    // each other's local providers, only ancestors *above* the Navigator
    // do (that's why GameData/PlayerCubit, provided higher up in
    // HomePage, are fine ambiently and don't need this). Captured here,
    // from the real caller's context, and re-provided by value — Quest
    // Board's "Begin Quest" reads it to flip WorldView over to the combat
    // page once a quest is created.
    final worldCubit = context.read<WorldCubit>();

    await showNavAwareModalSheet<void>(
      context,
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
                    style: QvTextStyles.banner.copyWith(color: colorScheme.onSecondary),
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
