import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/home/nav_aware_modal_sheet.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_draggable_sheet.dart';

/// A lighter modal-sheet shell than TownVisitSheet's "arrival banner" — a
/// title and a close button, nothing more. For quick in-context actions
/// reached from a Town Square list row (swap a piece of gear, reassign a
/// skill) that aren't "visiting a place" the way stepping into Forge or the
/// Shop is; see the Combat & Questing Redesign ticket. [body] is expected
/// to manage its own bounded layout (Expanded children, its own
/// scrollables) — see QvDraggableSheet.scrollableBody's own doc comment for
/// why this always passes false.
class QvPickerSheet extends StatelessWidget {
  const QvPickerSheet({super.key, required this.title, required this.body});

  final String title;
  final Widget body;

  static Future<void> showModal(
    BuildContext context, {
    required String title,
    required Widget body,
  }) {
    return showNavAwareModalSheet<void>(
      context,
      builder: (context) => QvPickerSheet(title: title, body: body),
    );
  }

  @override
  Widget build(BuildContext context) {
    return QvDraggableSheet(
      header: _PickerHeader(title: title),
      headerHeight: _PickerHeader.totalHeight,
      scrollableBody: false,
      body: body,
    );
  }
}

class _PickerHeader extends StatelessWidget {
  const _PickerHeader({required this.title});

  final String title;

  static const double _height = 44;
  static const double _bottomSpacing = 10;

  /// Total rendered height — QvDraggableSheet renders this as a fixed
  /// overlay above the body, so it needs to know how much room to reserve.
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
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
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
