import 'package:flutter/material.dart';

/// Selectable pill used for character tags — shared between the add-todo and
/// edit-todo forms (and the "add a new tag" affordance in the tags row).
class TagChip extends StatelessWidget {
  final IconData icon;
  final String name;
  final Color color;
  final bool isSelected;
  final void Function() onPressed;
  final EdgeInsets margin;

  const TagChip({
    super.key,
    required this.icon,
    required this.name,
    required this.color,
    required this.onPressed,
    this.isSelected = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 2),
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: margin,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected ? color : colorScheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: isSelected
              ? Border.all(
                  color: Colors.transparent,
                  width: 1.5,
                )
              : Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  width: 1.5,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withValues(alpha: 0.5),
              size: 16,
            ),
            Text(
              name,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
