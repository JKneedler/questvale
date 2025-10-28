import 'package:equatable/equatable.dart';
import 'package:questvale/cubits/todo_tab/add_todo/add_todo_state.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/todo.dart';

class EditTodoState extends Equatable {
  final Todo todo;
  final bool isCompleted;
  final String name;
  final String description;
  final DateTime? dueDate;
  final bool hasTime;
  final DifficultyLevel difficulty;
  final PriorityLevel priority;
  final List<Tag> availableTags;
  final List<Tag> selectedTags;
  final List<ReminderType> reminders;

  const EditTodoState({
    required this.todo,
    required this.isCompleted,
    required this.name,
    required this.description,
    required this.dueDate,
    required this.hasTime,
    required this.difficulty,
    required this.priority,
    this.availableTags = const [],
    required this.selectedTags,
    required this.reminders,
  });

  EditTodoState copyWith({
    Todo? todo,
    bool? isCompleted,
    String? name,
    String? description,
    DateTime? dueDate,
    bool? hasTime,
    DifficultyLevel? difficulty,
    PriorityLevel? priority,
    List<Tag>? availableTags,
    List<Tag>? selectedTags,
    List<ReminderType>? reminders,
  }) {
    return EditTodoState(
      todo: todo ?? this.todo,
      isCompleted: isCompleted ?? this.isCompleted,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      hasTime: hasTime ?? this.hasTime,
      difficulty: difficulty ?? this.difficulty,
      priority: priority ?? this.priority,
      availableTags: availableTags ?? this.availableTags,
      selectedTags: selectedTags ?? this.selectedTags,
      reminders: reminders ?? this.reminders,
    );
  }

  @override
  List<Object?> get props => [
        todo,
        isCompleted,
        name,
        description,
        dueDate,
        hasTime,
        difficulty,
        priority,
        availableTags,
        selectedTags,
        reminders
      ];
}
