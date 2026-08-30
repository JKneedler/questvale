import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/helpers/data_formatters.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_inset_background.dart';
import 'package:questvale/widgets/qv_text_styles.dart';

/// Month calendar grid shared between the todos calendar tab and the
/// due-date editor. Fully controlled — no internal state — so each caller
/// owns which month is displayed and which date is selected.
class QvMonthCalendar extends StatelessWidget {
  const QvMonthCalendar({
    super.key,
    required this.displayedMonth,
    required this.onMonthChanged,
    required this.onDateSelected,
    this.selectedDate,
    this.markedDates = const {},
    this.firstDate,
    this.lastDate,
  });

  final DateTime displayedMonth;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? selectedDate;
  final Set<DateTime> markedDates;
  final DateTime? firstDate;
  final DateTime? lastDate;

  static const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  // firstDate/lastDate often arrive as DateTime.now() — carrying today's
  // time-of-day rather than midnight — while each day cell below is built
  // at exactly midnight. Comparing those directly would mark today itself
  // as before firstDate (and thus disabled) for the rest of the day, so
  // both bounds are truncated to day-precision before comparing.
  bool _isOutOfRange(DateTime date) {
    if (firstDate != null) {
      final first = DateTime(firstDate!.year, firstDate!.month, firstDate!.day);
      if (date.isBefore(first)) return true;
    }
    if (lastDate != null) {
      final last = DateTime(lastDate!.year, lastDate!.month, lastDate!.day);
      if (date.isAfter(last)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();

    final firstOfMonth =
        DateTime(displayedMonth.year, displayedMonth.month, 1);
    final daysInMonth =
        DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday % 7;
    final totalCells = ((leadingBlanks + daysInMonth) / 7).ceil() * 7;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QvButton(
                width: 36,
                height: 36,
                buttonColor: ButtonColor.surfaceContainer,
                onTap: () => onMonthChanged(-1),
                child: Icon(Symbols.chevron_left,
                    color: colorScheme.onSurface, size: 20),
              ),
              QvInsetBackground(
                type: QvInsetBackgroundType.secondary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                child: Text(
                  DataFormatters.formatMonthYear(displayedMonth),
                  style: QvTextStyles.sectionHeader.copyWith(color: colorScheme.onSurface),
                ),
              ),
              QvButton(
                width: 36,
                height: 36,
                buttonColor: ButtonColor.surfaceContainer,
                onTap: () => onMonthChanged(1),
                child: Icon(Symbols.chevron_right,
                    color: colorScheme.onSurface, size: 20),
              ),
            ],
          ),
        ),
        Row(
          children: _weekdayLabels
              .map((label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: QvTextStyles.micro.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final dayNum = index - leadingBlanks + 1;
            if (dayNum < 1 || dayNum > daysInMonth) {
              return const SizedBox.shrink();
            }
            final date =
                DateTime(displayedMonth.year, displayedMonth.month, dayNum);
            final isSelected = selectedDate != null &&
                date.year == selectedDate!.year &&
                date.month == selectedDate!.month &&
                date.day == selectedDate!.day;
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
            final hasMark = markedDates.contains(date);
            final isDisabled = _isOutOfRange(date);

            final dayContent = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$dayNum',
                  style: QvTextStyles.body.copyWith(
                    color: isDisabled
                        ? colorScheme.onSurface.withValues(alpha: 0.25)
                        : isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                SizedBox(
                  height: 5,
                  child: hasMark
                      ? Icon(
                          Symbols.circle,
                          size: 5,
                          fill: 1,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.primary,
                        )
                      : null,
                ),
              ],
            );

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isDisabled ? null : () => onDateSelected(date),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: isSelected
                    ? QvButton(
                        padding: EdgeInsets.zero,
                        child: Center(child: dayContent),
                      )
                    : isToday
                        ? QvInsetBackground(
                            type: QvInsetBackgroundType.secondary,
                            padding: EdgeInsets.zero,
                            child: Center(child: dayContent),
                          )
                        : Center(child: dayContent),
              ),
            );
          },
        ),
      ],
    );
  }
}
