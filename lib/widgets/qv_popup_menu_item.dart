import 'package:flutter/material.dart';

class QvPopupMenuItem extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color? textColor;
  final Color? iconColor;
  final void Function() onPressed;

  const QvPopupMenuItem({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.textColor,
    this.iconColor,
  });

  @override
  State<QvPopupMenuItem> createState() => _QvPopupMenuItemState();
}

class _QvPopupMenuItemState extends State<QvPopupMenuItem> {
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(widget.icon,
                color: widget.iconColor ?? colorScheme.onPrimary, weight: 600),
            const SizedBox(width: 8),
            Text(widget.text,
                style: TextStyle(
                  color: widget.textColor ?? colorScheme.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}
