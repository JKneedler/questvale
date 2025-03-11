import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class QvPopupMenuCheckItem extends StatefulWidget {
  final String text;
  final bool isChecked;
  final void Function() onPressed;

  const QvPopupMenuCheckItem({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isChecked,
  });

  @override
  State<QvPopupMenuCheckItem> createState() => _QvPopupMenuCheckItemState();
}

class _QvPopupMenuCheckItemState extends State<QvPopupMenuCheckItem> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (details) {
        setState(() => isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => isPressed = false),
      child: Container(
        color: isPressed
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainerHigh,
        height: 44,
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(widget.text,
                  style: TextStyle(
                    color: widget.isChecked
                        ? colorScheme.primary
                        : colorScheme.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            if (widget.isChecked)
              Icon(Symbols.check, color: colorScheme.primary, weight: 600),
          ],
        ),
      ),
    );
  }
}
