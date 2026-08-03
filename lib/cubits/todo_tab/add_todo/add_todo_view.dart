import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/todo_tab/add_todo/add_todo_cubit.dart';
import 'package:questvale/cubits/todo_tab/add_todo/add_todo_state.dart';
import 'package:questvale/cubits/todo_tab/todo_form/todo_form_body.dart';
import 'package:questvale/cubits/todo_tab/todo_form/todo_form_sheet.dart';

class AddTodoView extends StatelessWidget {
  final VoidCallback onTodoAdded;

  const AddTodoView({
    super.key,
    required this.onTodoAdded,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddTodoCubit, AddTodoState>(
      builder: (context, state) {
        final cubit = context.read<AddTodoCubit>();
        final canSubmit = state.name.isNotEmpty;

        return TodoFormSheet(
          header: TodoFormHeader(
            onCancel: () => Navigator.of(context).pop(),
            confirmIcon: Symbols.add,
            onConfirm: !canSubmit
                ? null
                : () async {
                    await cubit.submit();
                    onTodoAdded();
                    if (context.mounted) Navigator.of(context).pop();
                  },
          ),
          body: TodoFormBody(
            characterId: state.characterId,
            showCompletionToggle: false,
            autofocusName: true,
            fields: TodoFormFields(
              name: state.name,
              description: state.description,
              dueDate: state.dueDate,
              hasTime: state.hasTime,
              reminders: state.reminders,
              difficulty: state.difficulty,
              priority: state.priority,
              isHabit: state.isHabit,
              timeframe: state.timeframe,
              allowsMultipleCompletions: state.allowsMultipleCompletions,
              repeatInterval: state.repeatInterval,
              repeatWeekdays: state.repeatWeekdays,
              monthlyRepeatMode: state.monthlyRepeatMode,
              availableTags: state.availableTags,
              selectedTags: state.selectedTags,
            ),
            callbacks: TodoFormCallbacks(
              onNameChanged: cubit.nameChanged,
              onDescriptionChanged: cubit.descriptionChanged,
              onTagToggled: cubit.toggleTag,
              onTagsReloaded: cubit.loadAvailableTags,
              onDueDateDaySelected: cubit.dueDateDaySelected,
              onDueDateTimeSelected: cubit.dueDateTimeSelected,
              onDueDateTimeCleared: cubit.dueDateTimeCleared,
              onReminderToggled: cubit.toggleReminder,
              onRemindersCleared: cubit.remindersCleared,
              onDueDateCleared: cubit.dueDateCleared,
              onDifficultyChanged: cubit.difficultyChanged,
              onPriorityChanged: cubit.priorityChanged,
              onHabitToggled: cubit.habitToggled,
              onTimeframeChanged: cubit.timeframeChanged,
              onMultipleCompletionsToggled: cubit.multipleCompletionsToggled,
              onRepeatIntervalChanged: cubit.repeatIntervalChanged,
              onRepeatWeekdayToggled: cubit.repeatWeekdayToggled,
              onMonthlyRepeatModeChanged: cubit.monthlyRepeatModeChanged,
            ),
          ),
        );
      },
    );
  }
}
