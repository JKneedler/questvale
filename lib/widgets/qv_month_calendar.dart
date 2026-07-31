import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/helpers/data_formatters.dart';

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

  bool _isOutOfRange(DateTime date) {
    if (firstDate != null && date.isBefore(firstDate!)) return true;
    if (lastDate != null && date.isAfter(lastDate!)) return true;
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
              GestureDetector(
                onTap: () => onMonthChanged(-1),
                child: Icon(Symbols.chevron_left,
                    color: colorScheme.onSurface, size: 28),
              ),
              Text(
                DataFormatters.formatMonthYear(displayedMonth),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => onMonthChanged(1),
                child: Icon(Symbols.chevron_right,
                    color: colorScheme.onSurface, size: 28),
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
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 12,
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

            return GestureDetector(
              onTap: isDisabled ? null : () => onDateSelected(date),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary : null,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: colorScheme.primary, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          color: isDisabled
                              ? colorScheme.onSurface.withValues(alpha: 0.25)
                              : isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
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
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
