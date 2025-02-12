import 'package:questvale/cubits/edit_task/edit_task_state.dart';
import 'package:questvale/data/models/checklist_item.dart';
import 'package:questvale/data/models/tag.dart';

class Task {
  static const taskTableName = 'Tasks';

  static const idColumnName = 'id';
  static const nameColumnName = 'name';
  static const descriptionColumnName = 'description';
  static const isCompletedColumnName = 'isCompleted';
  static const difficultyColumnName = 'difficulty';
  static const dueDateColumnName = 'dueDate';

  static const createTableSQL = '''
		CREATE TABLE ${Task.taskTableName}(
			${Task.idColumnName} VARCHAR PRIMARY KEY, 
			${Task.nameColumnName} VARCHAR NOT NULL, 
			${Task.descriptionColumnName} VARCHAR, 
			${Task.isCompletedColumnName} BOOLEAN,
			${Task.difficultyColumnName} INTEGER,
			${Task.dueDateColumnName} VARCHAR
		);
	''';

  final String id;
  final String name;
  final String description;
  final bool isCompleted;
  final DifficultyLevel difficulty;
  final String dueDate;
  final List<Tag> tags;
  final List<ChecklistItem> checklist;

  const Task(
      {required this.id,
      required this.name,
      required this.description,
      required this.isCompleted,
      required this.difficulty,
      required this.dueDate,
      required this.tags,
      required this.checklist});

  Map<String, Object?> toMap() {
    return {
      Task.idColumnName: id,
      Task.nameColumnName: name,
      Task.descriptionColumnName: description,
      Task.isCompletedColumnName: isCompleted ? 1 : 0,
      Task.difficultyColumnName: difficulty.index,
      Task.dueDateColumnName: dueDate,
    };
  }

  @override
  String toString() {
    final tagNameList = [for (Tag tag in tags) tag.name];
    final checklistItemNameList = [
      for (ChecklistItem checklistItem in checklist)
        '${checklistItem.name}: ${checklistItem.isCompleted}'
    ];
    return '''Task {
				id: $id
				name: $name
				description: $description
				isCompleted: $isCompleted
				difficulty: ${difficulty.toString()}
				dueDate: $dueDate
				tags: [${tagNameList.join(", ")}]
				checklist: [${checklistItemNameList.join(", ")}]
			}''';
  }

  Task copyWith({
    String? name,
    String? description,
    bool? isCompleted,
    DifficultyLevel? difficulty,
    String? dueDate,
    List<Tag>? tags,
    List<ChecklistItem>? checklist,
  }) {
    return Task(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      difficulty: difficulty ?? this.difficulty,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      checklist: checklist ?? this.checklist,
    );
  }
}
