import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/task.dart';

enum EditTaskStatus { edit, loading, done }

enum DifficultyLevel { trivial, easy, medium, hard }

class EditTaskState extends Equatable {
  final EditTaskStatus status;
  final Task? startTask;
  final String name;
  final String description;
  final String dueDate;
  final DifficultyLevel difficulty;
  final List<ChecklistStateItem> checklist;
  final List<TaskTags> tags;

  const EditTaskState({
    this.status = EditTaskStatus.edit,
    this.startTask,
    this.name = '',
    this.description = '',
    this.dueDate = '',
    this.difficulty = DifficultyLevel.medium,
    this.checklist = const [],
    this.tags = const [],
  });

  EditTaskState copyWith({
    EditTaskStatus? status,
    Task? startTask,
    String? name,
    String? description,
    String? dueDate,
    DifficultyLevel? difficulty,
    List<ChecklistStateItem>? checklist,
    List<TaskTags>? tags,
  }) {
    return EditTaskState(
      status: status ?? this.status,
      startTask: startTask ?? this.startTask,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      difficulty: difficulty ?? this.difficulty,
      checklist: checklist ?? this.checklist,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        status,
        startTask,
        name,
        description,
        dueDate,
        difficulty,
        checklist,
        tags
      ];

  @override
  String toString() {
    return '''EditTaskState(
								status: ${status.toString()} 
								name: $name
								description: $description
								dueDate: $dueDate
								difficulty: ${difficulty.toString()}
								checklist: [${checklist.join(", ")}]
								tags: [${tags.join(", ")}]
							)''';
  }
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
