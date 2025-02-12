import 'package:questvale/cubits/edit_task/edit_task_state.dart';
import 'package:questvale/data/models/checklist_item.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/task.dart';
import 'package:questvale/data/models/task_tag.dart';
import 'package:questvale/data/repositories/tag_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class TaskRepository {
  final Database db;

  late TagRepository tagRepository;

  TaskRepository({required this.db}) {
    tagRepository = TagRepository(db: db);
  }

  // GET all tasks
  Future<List<Task>> getTasks() async {
    final List<Map<String, Object?>> taskMaps =
        await db.query(Task.taskTableName);

    List<Task> tasks = [];
    for (final Map<String, Object?> taskMap in taskMaps) {
      final task = await _getTaskFromMap(taskMap);
      tasks.add(task);
    }

    return tasks;
  }

  // GET by id
  Future<Task> getTaskById(String id) async {
    final tasks = await db.query(Task.taskTableName,
        where: '${Task.idColumnName} = ?', whereArgs: [id], limit: 1);
    final task = await _getTaskFromMap(tasks[0]);
    return task;
  }

  // ADD
  Future<void> addTask(Task addTask) async {
    await db.insert(Task.taskTableName, addTask.toMap());
    final task = await getTaskById(addTask.id);

    for (Tag addTag in addTask.tags) {
      await db.insert(
        TaskTag.taskTagTableName,
        TaskTag(
          id: Uuid().v1(),
          task: task,
          tag: addTag,
        ).toMap(),
      );
    }

    for (ChecklistItem checklistItem in addTask.checklist) {
      await db.insert(
        ChecklistItem.checklistItemTableName,
        checklistItem.toMap(),
      );
    }
  }

  // UPDATE
  Future<void> updateTask(Task updateTask) async {
    await db.update(Task.taskTableName, updateTask.toMap(),
        where: '${Task.idColumnName} = ?', whereArgs: [updateTask.id]);

    // Checklist
    await db.delete(ChecklistItem.checklistItemTableName,
        where: '${ChecklistItem.taskColumnName} = ?',
        whereArgs: [updateTask.id]);
    for (ChecklistItem item in updateTask.checklist) {
      await db.insert(ChecklistItem.checklistItemTableName, item.toMap());
    }

    // Tags
    await db.delete(TaskTag.taskTagTableName,
        where: '${TaskTag.taskColumnName} = ?', whereArgs: [updateTask.id]);
    for (Tag tag in updateTask.tags) {
      await db.insert(TaskTag.taskTagTableName,
          TaskTag(id: Uuid().v1(), task: updateTask, tag: tag).toMap());
    }
  }

  // DELETE
  Future<void> deleteTask(Task taskToDelete) async {
    await db.delete(
      ChecklistItem.checklistItemTableName,
      where: '${ChecklistItem.taskColumnName} = ?',
      whereArgs: [taskToDelete.id],
    );
    await db.delete(
      TaskTag.taskTagTableName,
      where: '${TaskTag.taskColumnName} = ?',
      whereArgs: [taskToDelete.id],
    );
    await db.delete(
      Task.taskTableName,
      where: '${Task.idColumnName} = ?',
      whereArgs: [taskToDelete.id],
    );
  }

  // TODO temporary
  Future<void> logChecklistItems() async {
    final checklistItemMaps =
        await db.query(ChecklistItem.checklistItemTableName);
    print(checklistItemMaps);
  }

  // TODO temporary
  Future<void> logTasks() async {
    final taskMaps = await db.query(Task.taskTableName);
    print(taskMaps);
  }

  // TODO temporary
  Future<void> logTags() async {
    final tagMaps = await db.query(Tag.tagTableName);
    print(tagMaps);
  }

  // TODO temporary
  Future<void> logTaskTags() async {
    final taskTagMaps = await db.query(TaskTag.taskTagTableName);
    print(taskTagMaps);
  }

  Future<List<Tag>> _getTaskTags(String id) async {
    final List<Map<String, Object?>> taskTagMaps = await db.query(
        TaskTag.taskTagTableName,
        where: '${TaskTag.taskColumnName} = ?',
        whereArgs: [id]);

    List<Tag> tags = [];
    for (final Map<String, Object?> taskTagMap in taskTagMaps) {
      final Tag tag = await tagRepository
          .getTagById(taskTagMap[TaskTag.tagColumnName] as String);
      tags.add(tag);
    }
    return tags;
  }

  Future<List<ChecklistItem>> _getChecklist(Task task) async {
    final checklistItemMaps = await db.query(
      ChecklistItem.checklistItemTableName,
      where: '${ChecklistItem.taskColumnName} = ?',
      whereArgs: [task.id],
    );

    return [
      for (Map<String, Object?> cIMap in checklistItemMaps)
        ChecklistItem(
          id: cIMap[ChecklistItem.idColumnName] as String,
          task: task,
          name: cIMap[ChecklistItem.nameColumnName] as String,
          isCompleted:
              cIMap[ChecklistItem.isCompletedColumnName] == 1 ? true : false,
        )
    ];
  }

  Future<Task> _getTaskFromMap(Map<String, Object?> taskMap) async {
    List<Tag> tags = await _getTaskTags(taskMap[Task.idColumnName] as String);
    final task = Task(
      id: taskMap[Task.idColumnName] as String,
      name: taskMap[Task.nameColumnName] as String,
      description: taskMap[Task.descriptionColumnName] as String,
      isCompleted: taskMap[Task.isCompletedColumnName] == 1 ? true : false,
      difficulty:
          DifficultyLevel.values[taskMap[Task.difficultyColumnName] as int],
      dueDate: taskMap[Task.dueDateColumnName] as String,
      tags: tags,
      checklist: [],
    );
    List<ChecklistItem> checklist = await _getChecklist(task);

    return task.copyWith(checklist: checklist);
  }
}
