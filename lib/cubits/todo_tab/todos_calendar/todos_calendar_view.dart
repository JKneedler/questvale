import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todo_tab/todos_calendar/todos_calendar_cubit.dart';
import 'package:questvale/cubits/todo_tab/todos_calendar/todos_calendar_state.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_cubit.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_item.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_state.dart';
import 'package:questvale/widgets/qv_fading_scrollable.dart';
import 'package:questvale/widgets/qv_month_calendar.dart';

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

            final cubit = context.read<TodosCalendarCubit>();
            return Column(
              children: [
                QvMonthCalendar(
                  displayedMonth: calendarState.displayedMonth,
                  selectedDate: calendarState.selectedDate,
                  markedDates: dueDates,
                  onMonthChanged: cubit.changeMonth,
                  onDateSelected: cubit.selectDate,
                ),
                const SizedBox(height: 8),
                Container(height: 1, color: colorScheme.secondary),
                Expanded(
                  child: selectedDayTodos.isEmpty
                      ? Center(
                          child: Text(
                            'Nothing due this day',
                            style: TextStyle(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          ),
                        )
                      : QvFadingScrollable(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                                left: 6, right: 6, top: 10, bottom: 10),
                            itemCount: selectedDayTodos.length,
                            itemBuilder: (context, index) => TodosOverviewItem(
                                key: ValueKey(selectedDayTodos[index].id),
                                todo: selectedDayTodos[index]),
                          ),
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

