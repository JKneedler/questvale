import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/task.dart';

class TaskTag {
  static const taskTagTableName = 'TaskTags';

  static const idColumnName = 'id';
  static const taskColumnName = 'task';
  static const tagColumnName = 'tag';

  static const createTableSQL = '''
		CREATE TABLE ${TaskTag.taskTagTableName}(
			${TaskTag.idColumnName} VARCHAR PRIMARY KEY, 
			${TaskTag.taskColumnName} VARCHAR NOT NULL, 
			${TaskTag.tagColumnName} VARCHAR NOT NULL
		);
	''';

  final String id;
  final Task task;
  final Tag tag;

  const TaskTag({required this.id, required this.task, required this.tag});

  Map<String, Object?> toMap() {
    return {
      TaskTag.idColumnName: id,
      TaskTag.taskColumnName: task.id,
      TaskTag.tagColumnName: tag.id,
    };
  }

  @override
  String toString() {
    return 'TastTag {id: $id, task: ${task.id}, tag: ${tag.id}}';
  }

  TaskTag copyWith({
    Task? task,
    Tag? tag,
  }) {
    return TaskTag(id: id, task: task ?? this.task, tag: tag ?? this.tag);
  }
}
