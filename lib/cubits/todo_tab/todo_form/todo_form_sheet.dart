import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_draggable_sheet.dart';

/// Shared modal-sheet chrome for the add-todo and edit-todo screens.
/// Callers supply their own header (cancel/save actions differ between add
/// and edit) and body content; the actual DraggableScrollableSheet
/// machinery lives in QvDraggableSheet, shared with TownVisitSheet.
class TodoFormSheet extends StatelessWidget {
  const TodoFormSheet({
    super.key,
    required this.header,
    required this.body,
    this.footer,
  });

  final Widget header;
  final Widget body;

  /// Extra content below the body — currently only the edit-todo screen's
  /// delete button; a new todo doesn't exist yet, so add-todo has nothing
  /// to put here.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return QvDraggableSheet(
      header: header,
      headerHeight: TodoFormHeader.totalHeight,
      body: body,
      footer: footer,
    );
  }
}

/// Shared header row for the add-todo and edit-todo sheets: a close ("x")
/// button on the left, and a confirm button on the right whose icon differs
/// per caller (a "+" for creating, a checkmark for saving edits). Passing
/// null for [onConfirm] dims the confirm button and disables its tap.
class TodoFormHeader extends StatelessWidget {
  const TodoFormHeader({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.confirmIcon = Symbols.check,
  });

  final VoidCallback onCancel;
  final VoidCallback? onConfirm;
  final IconData confirmIcon;

  static const double _buttonHeight = 44;
  static const double _buttonWidth = _buttonHeight * 2;
  static const double _iconSize = 22;
  static const double _bottomSpacing = 12;

  /// Total rendered height (buttons + trailing spacing) — TodoFormSheet
  /// renders this header as a fixed overlay above the scrollable body, so it
  /// needs to know how much room to reserve for it.
  static const double totalHeight = _buttonHeight + _bottomSpacing;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: _bottomSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          QvButton(
            width: _buttonWidth,
            height: _buttonHeight,
            buttonColor: ButtonColor.surfaceContainer,
            onTap: onCancel,
            child: Icon(
              Symbols.close,
              weight: 700,
              size: _iconSize,
              color: colorScheme.onSurface,
            ),
          ),
          QvButton(
            width: _buttonWidth,
            height: _buttonHeight,
            buttonColor: ButtonColor.primary,
            onTap: onConfirm,
            child: Icon(
              confirmIcon,
              weight: 700,
              size: _iconSize,
              color: colorScheme.onPrimary
                  .withValues(alpha: onConfirm == null ? 0.4 : 1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width destructive action for the bottom of the edit-todo sheet.
class TodoFormDeleteButton extends StatelessWidget {
  const TodoFormDeleteButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return QvButton(
      width: double.infinity,
      height: 48,
      buttonColor: ButtonColor.surfaceContainer,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.delete, color: colorScheme.error, size: 20, weight: 600),
          const SizedBox(width: 8),
          Text(
            'Delete Todo',
            style: TextStyle(
              color: colorScheme.error,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
