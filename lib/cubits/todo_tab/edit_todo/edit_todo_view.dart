import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/todo_tab/edit_todo/edit_todo_cubit.dart';
import 'package:questvale/cubits/todo_tab/edit_todo/edit_todo_state.dart';
import 'package:questvale/cubits/todo_tab/todo_form/todo_form_body.dart';
import 'package:questvale/cubits/todo_tab/todo_form/todo_form_sheet.dart';
import 'package:questvale/data/models/todo.dart';

class EditTodoView extends StatelessWidget {
  final Todo todo;

  const EditTodoView({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<EditTodoCubit, EditTodoState>(
      builder: (context, state) {
        final cubit = context.read<EditTodoCubit>();

        return TodoFormSheet(
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Symbols.keyboard_arrow_down,
                  weight: 500,
                  size: 32,
                  color: colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: () {
                  cubit.submit();
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Symbols.check,
                  weight: 500,
                  size: 32,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          body: TodoFormBody(
            characterId: state.todo.characterId,
            showCompletionToggle: true,
            onCompletionToggled: cubit.toggleCompletion,
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
              availableTags: state.availableTags,
              selectedTags: state.selectedTags,
              isCompleted: state.isCompleted,
              currentStreak: state.todo.currentStreak,
            ),
            callbacks: TodoFormCallbacks(
              onNameChanged: cubit.nameChanged,
              onDescriptionChanged: cubit.descriptionChanged,
              onTagToggled: cubit.toggleTag,
              onTagsReloaded: cubit.loadTags,
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
            ),
          ),
        );
      },
    );
  }
}
