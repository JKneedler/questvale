import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/add_todo/add_todo_state.dart';
import 'package:questvale/cubits/edit_todo/edit_todo_state.dart';
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
          ),
        ) {
    _loadTags();
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

  Future<void> _loadTags() async {
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

  void hasTimeChanged(bool hasTime) {
    emit(state.copyWith(hasTime: hasTime));
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

    final updatedTodo = Todo(
      id: state.todo.id,
      name: state.name,
      description: state.description,
      isCompleted: state.todo.isCompleted,
      dueDate: state.dueDate,
      hasTime: state.hasTime,
      difficulty: state.difficulty,
      priority: state.priority,
      tags: state.selectedTags,
      reminders: todoReminders,
      characterId: state.todo.characterId,
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
