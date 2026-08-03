import 'package:flutter/material.dart';
import 'package:questvale/widgets/qv_button.dart';

/// A row of 7 independently-toggleable weekday buttons, for picking any
/// combination of days a weekly habit repeats on. Fully controlled — no
/// internal state — matching QvMonthCalendar/QvSegmentedControl. Labels
/// are Sunday-first single letters (S M T W T F S), matching
/// QvMonthCalendar's own weekday header row, but the values reported via
/// [onToggled] are Dart's own DateTime.weekday numbering (1=Mon..7=Sun) so
/// no translation layer is needed anywhere they're compared against a
/// DateTime's weekday.
class QvWeekdaySelector extends StatelessWidget {
  const QvWeekdaySelector({
    super.key,
    required this.selectedWeekdays,
    required this.onToggled,
  });

  final Set<int> selectedWeekdays;
  final ValueChanged<int> onToggled;

  static const _displayOrder = [7, 1, 2, 3, 4, 5, 6]; // Sun..Sat
  static const _labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Builder(builder: (context) {
              final weekday = _displayOrder[i];
              final isSelected = selectedWeekdays.contains(weekday);
              return QvButton(
                height: 40,
                buttonColor: isSelected
                    ? ButtonColor.primary
                    : ButtonColor.surfaceContainer,
                onTap: () => onToggled(weekday),
                child: Center(
                  child: Text(
                    _labels[i],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
