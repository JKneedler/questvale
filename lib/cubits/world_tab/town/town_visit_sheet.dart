import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/home/nav_aware_modal_sheet.dart';
import 'package:questvale/cubits/world_tab/world_cubit.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_draggable_sheet.dart';
import 'package:questvale/widgets/qv_text_styles.dart';

/// The shared "you have arrived" shell for every Town Square destination
/// (Quest Board, Shop, Guild Hall, Forge, Lab, Gemforge, Reliquary) — see
/// the Combat & Questing Redesign ticket. Replaces the old
/// TownCubit/TownLocation full-page slide-swap: Town Square is now the
/// permanent root and every destination opens as a tall modal sheet on top
/// of it, the same as AddTodo/EditTodo sitting on top of the Todo Overview
/// page — including covering the bottom nav bar entirely while open (see
/// showNavAwareModalSheet's own doc comment for the mechanics and the
/// provider-scoping fallout that comes with it). [iconPath] and [title]
/// reuse the same art/label already shown on the destination's row in
/// Town Square's list, so the banner reads as a continuation of what was
/// just tapped rather than a new, disconnected screen.
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
    // WorldCubit is provided *inside* WorldPage, one level further down
    // than PlayerCubit/GameData — showNavAwareModalSheet already re-provides
    // those two by value since it pushes onto the root Navigator (a sibling
    // route to HomePage's own, which doesn't share HomePage's local
    // providers — see its own doc comment), but has no way to know about
    // WorldCubit, which lives even further down inside WorldPage's own
    // subtree. Captured here, from the real caller's context, and
    // re-provided by value the same way — Quest Board's "Begin Quest" reads
    // it to flip WorldView over to the combat page once a quest is created.
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

/// Plain header — icon + title, a close button, nothing else. Previously an
/// ornate QvMetalCornerBorder "banner" box; simplified (per feedback, the
/// fancy pixel-art border wasn't earning its keep on every single town
/// destination) to match QvPickerSheet's own lighter header shape exactly,
/// just with the destination's icon added in front of the title. The two
/// sheet styles now share one header language instead of two.
class _TownVisitHeader extends StatelessWidget {
  const _TownVisitHeader({required this.title, required this.iconPath});

  final String title;
  final String iconPath;

  static const double _height = 44;
  static const double _bottomSpacing = 10;

  /// Total rendered height — QvDraggableSheet renders [_TownVisitHeader] as
  /// a fixed overlay above the scrollable/body region, so it needs to know
  /// exactly how much room to reserve.
  static const double totalHeight = _height + _bottomSpacing;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: _bottomSpacing),
      child: SizedBox(
        height: _height,
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 32,
              height: 32,
              filterQuality: FilterQuality.none,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: QvTextStyles.emphasis.copyWith(color: colorScheme.onSurface),
              ),
            ),
            const SizedBox(width: 12),
            QvButton(
              width: _height,
              height: _height,
              buttonColor: ButtonColor.surfaceContainer,
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Symbols.close,
                weight: 700,
                size: 18,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
