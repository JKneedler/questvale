import 'package:flutter/material.dart';
import 'package:questvale/widgets/qv_button.dart';

/// Shared row style for Town Square's scrollable list — equipment slots,
/// the skills row, potion/artifact placeholders, and town-location entries
/// all use this, matching TodosOverviewItem's own QvButton/surfaceContainer
/// row language so this page reads like the Todo tab's list. See the
/// Combat & Questing Redesign ticket.
class TownListRow extends StatelessWidget {
  const TownListRow({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.locked = false,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  // Grayscale + dims the title/subtitle — matches the old TownLocationCard's
  // level-gated look, now expressed as a row instead of a card.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final textColor = locked
        ? colorScheme.onSurface.withValues(alpha: 0.5)
        : colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: QvButton(
        buttonColor: ButtonColor.surfaceContainer,
        onTap: onTap,
        child: Material(
          color: Colors.transparent,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: locked
                    ? ColorFiltered(
                        colorFilter: const ColorFilter.matrix(<double>[
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: leading,
                      )
                    : leading,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 2,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '>',
                  style: TextStyle(fontSize: 20, color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
