import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return BlocBuilder<EditTodoCubit, EditTodoState>(
      builder: (context, state) {
        final cubit = context.read<EditTodoCubit>();

        return TodoFormSheet(
          header: TodoFormHeader(
            onCancel: () => Navigator.of(context).pop(),
            onConfirm: () {
              cubit.submit();
              Navigator.of(context).pop();
            },
          ),
          body: TodoFormBody(
            characterId: state.todo.characterId,
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
              currentStreak: state.todo.currentStreak,
            ),
            callbacks: TodoFormCallbacks(
              onNameChanged: cubit.nameChanged,
              onDescriptionChanged: cubit.descriptionChanged,
              onTagToggled: cubit.toggleTag,
              onTagCreated: cubit.createTag,
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
          footer: TodoFormDeleteButton(
            onTap: () => _confirmDelete(context, cubit),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, EditTodoCubit cubit) async {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainer,
        title: Text(
          'Delete Todo?',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          'This can\'t be undone.',
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child:
                Text('Cancel', style: TextStyle(color: colorScheme.onSurface)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Delete', style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await cubit.deleteTodo();
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
