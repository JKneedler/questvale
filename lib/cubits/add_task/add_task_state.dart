import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/task.dart';

enum AddTaskStatus { initial, loading, done }

class AddTaskState extends Equatable {
  final AddTaskStatus status;
  final String id;
  final String name;
  final String description;
  final String dueDate;
  final DifficultyLevel difficulty;
  final List<ChecklistStateItem> checklist;
  final List<TaskTags> tags;

  const AddTaskState({
    this.status = AddTaskStatus.initial,
    required this.id,
    this.name = '',
    this.description = '',
    this.dueDate = '',
    this.difficulty = DifficultyLevel.trivial,
    this.checklist = const [],
    this.tags = const [],
  });

  AddTaskState copyWith({
    AddTaskStatus? status,
    String? id,
    String? name,
    String? description,
    String? dueDate,
    DifficultyLevel? difficulty,
    List<ChecklistStateItem>? checklist,
    List<TaskTags>? tags,
  }) {
    return AddTaskState(
      status: status ?? this.status,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      difficulty: difficulty ?? this.difficulty,
      checklist: checklist ?? this.checklist,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props =>
      [status, id, name, description, dueDate, difficulty, checklist, tags];
}

class ChecklistStateItem {
  final String id;
  final String name;
  final bool isCompleted;

  const ChecklistStateItem({
    required this.id,
    required this.name,
    required this.isCompleted,
  });

  ChecklistStateItem copyWith({String? name, bool? isCompleted}) {
    return ChecklistStateItem(
      id: id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TaskTags {
  final String id;
  final String name;
  final bool isSelected;

  const TaskTags({
    required this.id,
    required this.name,
    required this.isSelected,
  });

  TaskTags copyWith({String? name, bool? isSelected}) {
    return TaskTags(
      id: id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
