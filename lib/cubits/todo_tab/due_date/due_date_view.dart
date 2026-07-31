import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/todo_tab/due_date/due_date_cubit.dart';
import 'package:questvale/cubits/todo_tab/due_date/due_date_editor.dart';
import 'package:questvale/cubits/todo_tab/due_date/due_date_state.dart';
import 'package:questvale/helpers/data_formatters.dart';

class DueDateView extends StatelessWidget {
  const DueDateView({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainerLow,
      child: BlocBuilder<DueDateCubit, DueDateState>(
        builder: (context, state) {
          final cubit = context.read<DueDateCubit>();
          return Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: TextStyle(color: colorScheme.primary)),
                    ),
                    if (state.selectedDate != null)
                      GestureDetector(
                        onTap: () => cubit.clearDueDate(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                DataFormatters.formatDateTime(
                                    state.selectedDate!, state.hasTime),
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Symbols.close,
                                color: colorScheme.error,
                                size: 20,
                                weight: 900,
                              ),
                            ],
                          ),
                        ),
                      ),
                    TextButton(
                      onPressed: () {
                        cubit.saveDueDate();
                        Navigator.pop(context);
                      },
                      child: Text('Done',
                          style: TextStyle(color: colorScheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                DueDateEditor(
                  selectedDate: state.selectedDate,
                  hasTime: state.hasTime,
                  reminders: state.reminders,
                  onDateSelected: cubit.updateSelectedDate,
                  onTimeSelected: cubit.updateSelectedTime,
                  onTimeCleared: cubit.clearSelectedTime,
                  onReminderToggled: cubit.toggleReminder,
                  onRemindersCleared: cubit.clearReminders,
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}
