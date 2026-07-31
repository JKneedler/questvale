import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todo_tab/add_todo/add_todo_state.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/todo_reminder.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/services/habit_service.dart';
import 'package:questvale/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class AddTodoCubit extends Cubit<AddTodoState> {
  final TodoRepository todoRepository;
  final CharacterRepository characterRepository;
  final String characterId;

  AddTodoCubit(this.todoRepository, this.characterRepository, this.characterId)
      : super(AddTodoState(
          id: const Uuid().v4(),
          characterId: characterId,
        )) {
    loadAvailableTags();
  }

  Future<void> loadAvailableTags() async {
    final availableTags =
        await characterRepository.getCharacterTags(characterId);
    emit(
      state.copyWith(
        availableTags: availableTags
            .map((tag) => Tag(
                  characterTagId: tag.id,
                  name: tag.name,
                  colorIndex: tag.colorIndex,
                  iconIndex: tag.iconIndex,
                ))
            .toList(),
      ),
    );
  }

  void nameChanged(String value) {
    emit(state.copyWith(name: value));
  }

  void descriptionChanged(String value) {
    emit(state.copyWith(description: value));
  }

  // Mirrors DueDateCubit.updateSelectedDate: a bare calendar day (from a
  // quick-select shortcut or the calendar grid) keeps the existing
  // time-of-day if one is already set, rather than clobbering it back to
  // midnight.
  void dueDateDaySelected(DateTime date) {
    final merged = state.hasTime && state.dueDate != null
        ? state.dueDate!.copyWith(
            year: date.year, month: date.month, day: date.day)
        : date;
    emit(state.copyWith(dueDate: merged));
  }

  // Mirrors DueDateCubit.updateSelectedTime: resets reminders when time is
  // being turned on for the first time, since the without-time and
  // with-time ReminderType sets are disjoint.
  void dueDateTimeSelected(TimeOfDay time) {
    final date = state.dueDate ?? DateTime.now();
    emit(state.copyWith(
      dueDate: date.copyWith(hour: time.hour, minute: time.minute),
      hasTime: true,
      reminders: state.hasTime ? state.reminders : [],
    ));
  }

  void dueDateTimeCleared() {
    emit(state.copyWith(hasTime: false, reminders: const []));
  }

  void toggleReminder(ReminderType reminder) {
    emit(state.copyWith(
      reminders: state.reminders.contains(reminder)
          ? state.reminders.where((e) => e != reminder).toList()
          : [...state.reminders, reminder],
    ));
  }

  void remindersCleared() {
    emit(state.copyWith(reminders: const []));
  }

  // state.copyWith can't null out dueDate (its `?? this.dueDate` fallback
  // treats an explicit null as "unchanged"), so this constructs the state
  // directly instead — same workaround habitToggled uses for timeframe.
  void dueDateCleared() {
    emit(AddTodoState(
      status: state.status,
      characterId: state.characterId,
      id: state.id,
      name: state.name,
      description: state.description,
      dueDate: null,
      hasTime: false,
      difficulty: state.difficulty,
      priority: state.priority,
      availableTags: state.availableTags,
      selectedTags: state.selectedTags,
      reminders: const [],
      isHabit: state.isHabit,
      timeframe: state.timeframe,
      allowsMultipleCompletions: state.allowsMultipleCompletions,
    ));
  }

  void difficultyChanged(DifficultyLevel value) {
    emit(state.copyWith(difficulty: value));
  }

  void priorityChanged(PriorityLevel value) {
    emit(state.copyWith(priority: value));
  }

  void habitToggled(bool value) {
    emit(AddTodoState(
      id: state.id,
      characterId: state.characterId,
      name: state.name,
      description: state.description,
      dueDate: state.dueDate,
      hasTime: state.hasTime,
      difficulty: state.difficulty,
      priority: state.priority,
      availableTags: state.availableTags,
      selectedTags: state.selectedTags,
      status: state.status,
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

  void toggleTag(Tag tag) {
    if (state.selectedTags.contains(tag)) {
      emit(state.copyWith(
          selectedTags: state.selectedTags.where((t) => t != tag).toList()));
    } else {
      emit(state.copyWith(selectedTags: [...state.selectedTags, tag]));
    }
  }

  Future<void> submit() async {
    if (state.name.isEmpty) {
      return; // Don't submit if name is empty
    }
    emit(state.copyWith(status: AddTodoStatus.loading));

    try {
      final todo = Todo(
        id: state.id,
        characterId: characterId,
        name: state.name,
        description: state.description,
        dueDate: state.dueDate,
        difficulty: state.difficulty,
        priority: state.priority,
        isCompleted: false,
        tags: state.selectedTags,
        hasTime: state.hasTime,
        reminders: _createRemindersForTodo(state.id),
        isHabit: state.isHabit,
        timeframe: state.timeframe,
        allowsMultipleCompletions: state.allowsMultipleCompletions,
        currentPeriodStart: state.isHabit
            ? HabitService.startOfPeriodContaining(DateTime.now())
            : null,
      );

      await todoRepository.createTodo(todo);
      for (final reminder in todo.reminders) {
        await NotificationService()
            .scheduleReminder(reminder, title: todo.name);
      }
      emit(AddTodoState(
        status: AddTodoStatus.initial,
        id: const Uuid().v4(),
        characterId: characterId,
        name: '',
        description: '',
        dueDate: null,
        hasTime: false,
        difficulty: DifficultyLevel.trivial,
        priority: PriorityLevel.noPriority,
        selectedTags: [],
        reminders: [],
        isHabit: false,
        timeframe: null,
        allowsMultipleCompletions: false,
      ));
    } catch (e) {
      // Handle error
      emit(state.copyWith(status: AddTodoStatus.initial));
    }
  }

  List<TodoReminder> _createRemindersForTodo(String todoId) {
    final reminders = state.reminders;
    List<TodoReminder> todoReminders = [];
    for (ReminderType reminder in reminders) {
      DateTime reminderDateTime = state.dueDate ?? DateTime.now();
      switch (reminder) {
        case ReminderType.atTimeWithoutTime:
          reminderDateTime = DateTime.now();
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
          reminderType: reminder,
        ),
      );
    }
    return todoReminders;
  }
}
