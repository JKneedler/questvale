import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todo_tab/edit_todo/edit_todo_state.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/todo_reminder.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:questvale/services/habit_service.dart';
import 'package:questvale/services/notification_service.dart';
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
            reminders: todo.reminders
                .where((r) => r.reminderType != null)
                .map((r) => r.reminderType!)
                .toList(),
            isHabit: todo.isHabit,
            timeframe: todo.timeframe,
            allowsMultipleCompletions: todo.allowsMultipleCompletions,
            repeatInterval: todo.repeatInterval,
            repeatWeekdays: todo.repeatWeekdays,
            monthlyRepeatMode: todo.monthlyRepeatMode,
          ),
        ) {
    loadTags();
  }

  Future<void> loadTags() async {
    final characterTags =
        await characterRepository.getCharacterTags(state.todo.characterId);
    // Convert CharacterTag to Tag
    final tags = characterTags
        .map((ct) => Tag(
              characterTagId: ct.id,
              name: ct.name,
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

  void remindersCleared() {
    emit(state.copyWith(reminders: const []));
  }

  // state.copyWith can't null out dueDate (its `?? this.dueDate` fallback
  // treats an explicit null as "unchanged"), so this constructs the state
  // directly instead — same workaround habitToggled uses for timeframe.
  void dueDateCleared() {
    emit(EditTodoState(
      todo: state.todo,
      isCompleted: state.isCompleted,
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
      repeatInterval: state.repeatInterval,
      repeatWeekdays: state.repeatWeekdays,
      monthlyRepeatMode: state.monthlyRepeatMode,
    ));
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
      repeatInterval: value ? state.repeatInterval : 1,
      repeatWeekdays: value ? state.repeatWeekdays : const {},
      monthlyRepeatMode:
          value ? state.monthlyRepeatMode : MonthlyRepeatMode.dayOfMonth,
    ));
  }

  // See AddTodoCubit.timeframeChanged for why repeatInterval always resets
  // and repeatWeekdays is seeded/cleared on entering/leaving Weekly.
  void timeframeChanged(HabitTimeframe value) {
    Set<int> weekdays = state.repeatWeekdays;
    if (value == HabitTimeframe.weekly) {
      if (weekdays.isEmpty) {
        weekdays = {(state.dueDate ?? DateTime.now()).weekday};
      }
    } else {
      weekdays = const {};
    }
    emit(state.copyWith(
      isHabit: true,
      timeframe: value,
      repeatInterval: 1,
      repeatWeekdays: weekdays,
    ));
  }

  void multipleCompletionsToggled(bool value) {
    emit(state.copyWith(allowsMultipleCompletions: value));
  }

  void repeatIntervalChanged(int value) {
    emit(state.copyWith(repeatInterval: value));
  }

  void repeatWeekdayToggled(int weekday) {
    final updated = Set<int>.from(state.repeatWeekdays);
    if (updated.contains(weekday)) {
      updated.remove(weekday);
    } else {
      updated.add(weekday);
    }
    emit(state.copyWith(repeatWeekdays: updated));
  }

  void monthlyRepeatModeChanged(MonthlyRepeatMode value) {
    emit(state.copyWith(monthlyRepeatMode: value));
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
    // Habit, carry over untouched if it was already a Habit and its
    // repeat config didn't change, and clear if a Habit just became a
    // one-time Task again. A repeat-config-only change (interval,
    // weekdays, or monthly mode, on an already-existing habit) also needs
    // to re-anchor currentPeriodStart — otherwise day-gating or the
    // monthly "day of week" derivation could reflect the OLD config for
    // up to one full period after the edit.
    final wasHabit = state.todo.isHabit;
    final isNowHabit = state.isHabit;
    final repeatConfigChanged = state.timeframe != state.todo.timeframe ||
        state.repeatInterval != state.todo.repeatInterval ||
        !const SetEquality<int>()
            .equals(state.repeatWeekdays, state.todo.repeatWeekdays) ||
        state.monthlyRepeatMode != state.todo.monthlyRepeatMode;

    DateTime? currentPeriodStart;
    int completionsInCurrentPeriod;
    int currentStreak;
    bool completionAwarded;

    if (!isNowHabit) {
      currentPeriodStart = null;
      completionsInCurrentPeriod = 0;
      currentStreak = 0;
      completionAwarded = false;
    } else if (!wasHabit || repeatConfigChanged) {
      final anchorReference = (state.timeframe == HabitTimeframe.monthly &&
              state.monthlyRepeatMode == MonthlyRepeatMode.dayOfWeek &&
              state.dueDate != null)
          ? state.dueDate!
          : DateTime.now();
      currentPeriodStart = HabitService.anchorPeriodStart(
        timeframe: state.timeframe!,
        repeatWeekdays: state.repeatWeekdays,
        referenceDate: anchorReference,
      );
      completionsInCurrentPeriod = 0;
      // Preserved across a repeat-config tweak (only zeroed on a genuine
      // Task->Habit transition) — editing repeat settings shouldn't wipe
      // an earned streak.
      currentStreak = wasHabit ? state.todo.currentStreak : 0;
      completionAwarded = false;
    } else {
      currentPeriodStart = state.todo.currentPeriodStart;
      completionsInCurrentPeriod = state.todo.completionsInCurrentPeriod;
      currentStreak = state.todo.currentStreak;
      completionAwarded = state.todo.completionAwarded;
    }

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
      completionAwarded: completionAwarded,
      repeatInterval: state.repeatInterval,
      repeatWeekdays: state.repeatWeekdays,
      monthlyRepeatMode: state.monthlyRepeatMode,
    );

    await todoRepository.updateTodo(updatedTodo);

    // Every submit rebuilds the reminders list with fresh ids (see
    // _createRemindersForTodo), so the old scheduled notifications need to
    // be cancelled explicitly — their DB rows are already gone.
    for (final oldReminder in state.todo.reminders) {
      await NotificationService().cancelReminder(oldReminder.id);
    }
    for (final reminder in todoReminders) {
      await NotificationService()
          .scheduleReminder(reminder, title: updatedTodo.name);
    }
  }

  Future<void> deleteTodo() async {
    await todoRepository.deleteTodo(state.todo);
    for (final reminder in state.todo.reminders) {
      await NotificationService().cancelReminder(reminder.id);
    }
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
          reminderType: reminder,
        ),
      );
    }
    return todoReminders;
  }
}
