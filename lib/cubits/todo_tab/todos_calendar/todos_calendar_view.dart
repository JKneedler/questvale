import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/todo_tab/todos_calendar/todos_calendar_cubit.dart';
import 'package:questvale/cubits/todo_tab/todos_calendar/todos_calendar_state.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_cubit.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_item.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_state.dart';
import 'package:questvale/helpers/data_formatters.dart';

// Rendered inline in TodosOverviewView when viewMode is calendar — no
// Scaffold/QvAppBar of its own, so the three-dot menu stays put and swapping
// back to the list is just another state change, not a page pop.
class TodosCalendarBody extends StatelessWidget {
  const TodosCalendarBody({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<TodosOverviewCubit, TodosOverviewState>(
      builder: (context, overviewState) {
        return BlocBuilder<TodosCalendarCubit, TodosCalendarState>(
          builder: (context, calendarState) {
            final dueDates = <DateTime>{
              for (final todo in overviewState.todos)
                if (todo.dueDate != null)
                  DateTime(todo.dueDate!.year, todo.dueDate!.month,
                      todo.dueDate!.day),
            };
            final selectedDayTodos = overviewState.todos.where((todo) {
              if (todo.dueDate == null) return false;
              final d = todo.dueDate!;
              return d.year == calendarState.selectedDate.year &&
                  d.month == calendarState.selectedDate.month &&
                  d.day == calendarState.selectedDate.day;
            }).toList();

            return Column(
              children: [
                _MonthHeader(month: calendarState.displayedMonth),
                _MonthGrid(
                  displayedMonth: calendarState.displayedMonth,
                  selectedDate: calendarState.selectedDate,
                  dueDates: dueDates,
                ),
                const SizedBox(height: 8),
                Container(height: 1, color: colorScheme.secondary),
                Expanded(
                  child: selectedDayTodos.isEmpty
                      ? Center(
                          child: Text(
                            'Nothing due this day',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                              left: 6, right: 6, top: 10, bottom: 10),
                          itemCount: selectedDayTodos.length,
                          itemBuilder: (context, index) =>
                              TodosOverviewItem(todo: selectedDayTodos[index]),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  const _MonthHeader({required this.month});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final cubit = context.read<TodosCalendarCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => cubit.changeMonth(-1),
            child: Icon(Symbols.chevron_left,
                color: colorScheme.onSurface, size: 28),
          ),
          Text(
            DataFormatters.formatMonthYear(month),
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () => cubit.changeMonth(1),
            child: Icon(Symbols.chevron_right,
                color: colorScheme.onSurface, size: 28),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Set<DateTime> dueDates;

  const _MonthGrid({
    required this.displayedMonth,
    required this.selectedDate,
    required this.dueDates,
  });

  static const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final cubit = context.read<TodosCalendarCubit>();
    final today = DateTime.now();

    final firstOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final daysInMonth =
        DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday % 7;
    final totalCells = ((leadingBlanks + daysInMonth) / 7).ceil() * 7;

    return Column(
      children: [
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
            final isSelected = date.year == selectedDate.year &&
                date.month == selectedDate.month &&
                date.day == selectedDate.day;
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
            final hasDue = dueDates.contains(date);

            return GestureDetector(
              onTap: () => cubit.selectDate(date),
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
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                        child: hasDue
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
