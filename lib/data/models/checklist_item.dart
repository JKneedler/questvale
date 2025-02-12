import 'package:questvale/data/models/task.dart';

class ChecklistItem {
  static const checklistItemTableName = 'ChecklistItems';

  static const idColumnName = 'id';
  static const taskColumnName = 'task';
  static const nameColumnName = 'name';
  static const isCompletedColumnName = 'isCompleted';

  static const createTableSQL = '''
		CREATE TABLE ${ChecklistItem.checklistItemTableName}(
			${ChecklistItem.idColumnName} VARCHAR PRIMARY KEY, 
			${ChecklistItem.taskColumnName} VARCHAR NOT NULL,
			${ChecklistItem.nameColumnName} VARCHAR NOT NULL,
			${ChecklistItem.isCompletedColumnName} BOOLEAN
		);
	''';

  final String id;
  final Task task;
  final String name;
  final bool isCompleted;

  const ChecklistItem({
    required this.id,
    required this.task,
    required this.name,
    required this.isCompleted,
  });

  Map<String, Object?> toMap() {
    return {
      ChecklistItem.idColumnName: id,
      ChecklistItem.taskColumnName: task.id,
      ChecklistItem.nameColumnName: name,
      ChecklistItem.isCompletedColumnName: isCompleted ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'ChecklistItem {id: $id, task: ${task.name}, name: $name, isCompleted: $isCompleted}';
  }

  ChecklistItem copyWith({
    Task? task,
    String? name,
    bool? isCompleted,
  }) {
    return ChecklistItem(
      id: id,
      task: task ?? this.task,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
