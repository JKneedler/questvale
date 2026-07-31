import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/widgets/qv_background.dart';
import 'package:questvale/widgets/qv_button.dart';

/// Shared modal-sheet chrome for the add-todo and edit-todo screens: a
/// DraggableScrollableSheet (so dragging down from the top of the content
/// hands off to the modal's own dismiss animation via shouldCloseOnMinExtent)
/// wrapping a scrollable QvBackground. Callers supply their own header
/// (cancel/save actions differ between add and edit) and body content.
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
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.92,
      minChildSize: 0.1,
      expand: false,
      snap: true,
      builder: (context, scrollController) {
        return QvBackground(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(16),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const CalmSnapScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  body,
                  if (footer != null) ...[
                    const SizedBox(height: 8),
                    footer!,
                  ],
                ],
              ),
            ),
          ),
        );
      },
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

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

/// DraggableScrollableSheet's snap-on-release only picks the *nearest* snap
/// size (min or max) when the release velocity is within tolerance;
/// otherwise it jumps to the next size in the fling's direction, however far
/// that is. The default tolerance is only a few px/s, so almost any
/// perceptible release velocity counts as a fling and can send a small drag
/// near the top of the content all the way down to the dismiss size.
/// Widening the velocity tolerance means only a deliberate fast flick
/// triggers that directional jump; slower releases settle on whichever size
/// (open or dismiss) is actually closer.
class CalmSnapScrollPhysics extends ScrollPhysics {
  const CalmSnapScrollPhysics({super.parent});

  @override
  CalmSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CalmSnapScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Tolerance toleranceFor(ScrollMetrics metrics) {
    final defaultTolerance = super.toleranceFor(metrics);
    return Tolerance(
      velocity: 1000,
      distance: defaultTolerance.distance,
      time: defaultTolerance.time,
    );
  }
}
