import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todo_tab/add_todo/add_todo_state.dart';
import 'package:questvale/cubits/todo_tab/edit_todo/edit_todo_state.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/todo_reminder.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:uuid/uuid.dart';

class EditTodoCubit extends Cubit<EditTodoState> {
  final TodoRepository todoRepository;
  final CharacterRepository characterRepository;

  EditTodoCubit({
    required this.todoRepository,
    required this.characterRepository,
    required Todo todo,
  }) : super(
          EditTodoState(
            todo: todo,
            isCompleted: todo.isCompleted,
            name: todo.name,
            description: todo.description,
            dueDate: todo.dueDate,
            hasTime: todo.hasTime,
            difficulty: todo.difficulty,
            priority: todo.priority,
            selectedTags: todo.tags,
            reminders: _convertTodoRemindersToReminderTypes(
                todo.reminders, todo.hasTime),
            isHabit: todo.isHabit,
            timeframe: todo.timeframe,
            allowsMultipleCompletions: todo.allowsMultipleCompletions,
          ),
        ) {
    loadTags();
  }

  // Helper method to convert TodoReminder to ReminderType
  static List<ReminderType> _convertTodoRemindersToReminderTypes(
      List<TodoReminder> todoReminders, bool hasTime) {
    // This is a simplified conversion - in a real app, you would determine the ReminderType
    // based on the time difference between the due date and reminder time
    return todoReminders.map((reminder) {
      if (hasTime) {
        return ReminderType.oneHourBeforeWithTime;
      } else {
        return ReminderType.oneDayBeforeWithoutTime;
      }
    }).toList();
  }

  Future<void> loadTags() async {
    final characterTags =
        await characterRepository.getCharacterTags(state.todo.characterId);
    // Convert CharacterTag to Tag
    final tags = characterTags
        .map((ct) => Tag(
              characterTagId: ct.id,
              name: ct.name,
              colorIndex: ct.colorIndex,
              iconIndex: ct.iconIndex,
            ))
        .toList();
    emit(state.copyWith(availableTags: tags));
  }

  void toggleCompletion() {
    emit(state.copyWith(isCompleted: !state.isCompleted));
  }

  void nameChanged(String name) {
    emit(state.copyWith(name: name));
  }

  void descriptionChanged(String description) {
    emit(state.copyWith(description: description));
  }

  void dueDateChanged(DateTime? dueDate) {
    emit(state.copyWith(dueDate: dueDate));
  }

  // Matches DueDatePage's onDateSelected callback contract so the edit view
  // can reuse the same due-date/time/reminders sub-modal as the add form.
  void dueDateAndRemindersChanged(
      DateTime? date, bool hasTime, List<ReminderType> reminders) {
    emit(EditTodoState(
      todo: state.todo,
      isCompleted: state.isCompleted,
      name: state.name,
      description: state.description,
      dueDate: date,
      hasTime: hasTime,
      difficulty: state.difficulty,
      priority: state.priority,
      availableTags: state.availableTags,
      selectedTags: state.selectedTags,
      reminders: reminders,
      isHabit: state.isHabit,
      timeframe: state.timeframe,
      allowsMultipleCompletions: state.allowsMultipleCompletions,
    ));
  }

  void hasTimeChanged(bool hasTime) {
    emit(state.copyWith(hasTime: hasTime));
  }

  void habitToggled(bool value) {
    emit(EditTodoState(
      todo: state.todo,
      isCompleted: state.isCompleted,
      name: state.name,
      description: state.description,
      dueDate: state.dueDate,
      hasTime: state.hasTime,
      difficulty: state.difficulty,
      priority: state.priority,
      availableTags: state.availableTags,
      selectedTags: state.selectedTags,
      reminders: state.reminders,
      isHabit: value,
      timeframe: value ? (state.timeframe ?? HabitTimeframe.daily) : null,
      allowsMultipleCompletions:
          value ? state.allowsMultipleCompletions : false,
    ));
  }

  void timeframeChanged(HabitTimeframe value) {
    emit(state.copyWith(isHabit: true, timeframe: value));
  }

  void multipleCompletionsToggled(bool value) {
    emit(state.copyWith(allowsMultipleCompletions: value));
  }

  void difficultyChanged(DifficultyLevel difficulty) {
    emit(state.copyWith(difficulty: difficulty));
  }

  void priorityChanged(PriorityLevel priority) {
    emit(state.copyWith(priority: priority));
  }

  void toggleTag(Tag tag) {
    final selectedTags = List<Tag>.from(state.selectedTags);
    if (selectedTags.any((t) => t.characterTagId == tag.characterTagId)) {
      selectedTags.removeWhere((t) => t.characterTagId == tag.characterTagId);
    } else {
      selectedTags.add(tag);
    }
    emit(state.copyWith(selectedTags: selectedTags));
  }

  void toggleReminder(ReminderType reminder) {
    final reminders = List<ReminderType>.from(state.reminders);
    if (reminders.contains(reminder)) {
      reminders.remove(reminder);
    } else {
      reminders.add(reminder);
    }
    emit(state.copyWith(reminders: reminders));
  }

  Future<void> submit() async {
    if (state.name.isEmpty) {
      return; // Don't submit if name is empty
    }

    // Create TodoReminders from ReminderTypes
    final todoReminders = _createRemindersForTodo(state.todo.id);

    // Habit fields (streak/completion count) reset if a Task just became a
    // Habit, carry over untouched if it was already a Habit, and clear if a
    // Habit just became a one-time Task again.
    final wasHabit = state.todo.isHabit;
    final isNowHabit = state.isHabit;
    final currentPeriodStart = isNowHabit
        ? (wasHabit ? state.todo.currentPeriodStart : DateTime.now())
        : null;
    final completionsInCurrentPeriod =
        isNowHabit && wasHabit ? state.todo.completionsInCurrentPeriod : 0;
    final currentStreak = isNowHabit && wasHabit ? state.todo.currentStreak : 0;

    final updatedTodo = Todo(
      id: state.todo.id,
      name: state.name,
      description: state.description,
      isCompleted: state.isCompleted,
      dueDate: state.dueDate,
      hasTime: state.hasTime,
      difficulty: state.difficulty,
      priority: state.priority,
      tags: state.selectedTags,
      reminders: todoReminders,
      characterId: state.todo.characterId,
      isHabit: isNowHabit,
      timeframe: state.timeframe,
      allowsMultipleCompletions: state.allowsMultipleCompletions,
      currentPeriodStart: currentPeriodStart,
      completionsInCurrentPeriod: completionsInCurrentPeriod,
      currentStreak: currentStreak,
    );

    await todoRepository.updateTodo(updatedTodo);
  }

  // Create TodoReminders from ReminderTypes
  List<TodoReminder> _createRemindersForTodo(String todoId) {
    final reminders = state.reminders;
    List<TodoReminder> todoReminders = [];
    for (ReminderType reminder in reminders) {
      DateTime reminderDateTime = state.dueDate ?? DateTime.now();
      switch (reminder) {
        case ReminderType.atTimeWithoutTime:
          reminderDateTime = reminderDateTime;
          break;
        case ReminderType.oneDayBeforeWithoutTime:
          reminderDateTime = reminderDateTime.subtract(Duration(days: 1));
          break;
        case ReminderType.twoDaysBeforeWithoutTime:
          reminderDateTime = reminderDateTime.subtract(Duration(days: 2));
          break;
        case ReminderType.threeDeysBeforeWithoutTime:
          reminderDateTime = reminderDateTime.subtract(Duration(days: 3));
          break;
        case ReminderType.oneWeekBeforeWithoutTime:
          reminderDateTime = reminderDateTime.subtract(Duration(days: 7));
          break;
        case ReminderType.atTimeWithTime:
          reminderDateTime = reminderDateTime;
          break;
        case ReminderType.fiveMinutesBeforeWithTime:
          reminderDateTime = reminderDateTime.subtract(Duration(minutes: 5));
          break;
        case ReminderType.thirtyMinutesBeforeWithTime:
          reminderDateTime = reminderDateTime.subtract(Duration(minutes: 30));
          break;
        case ReminderType.oneHourBeforeWithTime:
          reminderDateTime = reminderDateTime.subtract(Duration(hours: 1));
          break;
        case ReminderType.oneDayBeforeWithTime:
          reminderDateTime = reminderDateTime.subtract(Duration(days: 1));
          break;
      }
      todoReminders.add(
        TodoReminder(
          id: const Uuid().v4(),
          todoId: todoId,
          dateTime: reminderDateTime,
        ),
      );
    }
    return todoReminders;
  }
}
