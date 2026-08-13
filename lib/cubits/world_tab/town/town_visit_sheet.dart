import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/world_cubit.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_draggable_sheet.dart';
import 'package:questvale/widgets/qv_metal_corner_border.dart';

/// The shared "you have arrived" shell for every Town Square destination
/// (Quest Board, Shop, Guild Hall, Forge, Lab, Gemforge, Reliquary) — see
/// the Combat & Questing Redesign ticket. Replaces the old
/// TownCubit/TownLocation full-page slide-swap: Town Square is now the
/// permanent root and every destination opens as a tall modal sheet on top
/// of it, mirroring how AddTodo/EditTodo sit on top of the Todo Overview
/// page. [iconPath] and [title] reuse the same art/label already shown on
/// the destination's TownLocationCard, so the banner reads as a
/// continuation of what was just tapped rather than a new, disconnected
/// screen.
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
  }) {
    // GameData/PlayerCubit/WorldCubit are all provided somewhere inside
    // HomePage's own subtree (see home_page.dart/world_page.dart) — not
    // above MaterialApp the way Database/ThemeCubit are (main.dart). The
    // useRootNavigator below pushes this sheet onto the app's *root*
    // Navigator so its overlay actually covers the bottom nav bar (see
    // AddTodoPage.showModal's own doc comment for why), but that Navigator
    // sits above HomePage's provider scope — so every destination's own
    // content (which already assumes ambient access to these, unchanged
    // from when it only ever lived inside that scope) needs them
    // re-provided by value around the sheet, captured here from the real
    // caller's context before the modal route is pushed.
    final gameData = context.read<GameData>();
    final playerCubit = context.read<PlayerCubit>();
    final worldCubit = context.read<WorldCubit>();

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      useRootNavigator: true,
      builder: (context) => MultiProvider(
        providers: [
          Provider<GameData>.value(value: gameData),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<PlayerCubit>.value(value: playerCubit),
            BlocProvider<WorldCubit>.value(value: worldCubit),
          ],
          child: TownVisitSheet(
            title: title,
            iconPath: iconPath,
            scrollableBody: scrollableBody,
            body: body,
          ),
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
