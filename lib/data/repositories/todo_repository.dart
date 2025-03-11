import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/todo_reminder.dart';
import 'package:questvale/data/models/todo_tag.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class TodoRepository {
  final Database db;

  TodoRepository({required this.db});

  // GET all todos
  Future<List<Todo>> getTodosByCharacterId(String characterId) async {
    final List<Map<String, dynamic>> maps = await db.query(Todo.todoTableName,
        where: '${Todo.characterIdColumnName} = ?', whereArgs: [characterId]);
    final todos = await Future.wait(
      maps.map((map) => _getTodoFromMap(map)),
    );
    return todos;
  }

  // GET todo by id
  Future<Todo> getTodoById(String id) async {
    final todos = await db.query(Todo.todoTableName,
        where: '${Todo.idColumnName} = ?', whereArgs: [id], limit: 1);
    final todo = await _getTodoFromMap(todos[0]);
    return todo;
  }

  // UPDATE todo
  Future<void> updateTodo(Todo updateTodo) async {
    await db.update(Todo.todoTableName, updateTodo.toMap(),
        where: '${Todo.idColumnName} = ?', whereArgs: [updateTodo.id]);
  }

  // DELETE todo
  Future<void> deleteTodo(Todo todoToDelete) async {
    await db.delete(
      Todo.todoTableName,
      where: '${Todo.idColumnName} = ?',
      whereArgs: [todoToDelete.id],
    );
  }

  // INSERT todo
  Future<void> createTodo(Todo todo) async {
    await db.insert(
      Todo.todoTableName,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (final tag in todo.tags) {
      await db.insert(
        TodoTag.todoTagTableName,
        {
          TodoTag.idColumnName: const Uuid().v4(),
          TodoTag.todoIdColumnName: todo.id,
          TodoTag.characterTagIdColumnName: tag.characterTagId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (final reminder in todo.reminders) {
      await db.insert(
        TodoReminder.todoReminderTableName,
        reminder.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // GET todo from map
  Future<Todo> _getTodoFromMap(Map<String, dynamic> map) async {
    final tags = await _getTagsForTodo(map[Todo.idColumnName] as String);
    final reminders =
        await _getRemindersForTodo(map[Todo.idColumnName] as String);
    return Todo(
      id: map[Todo.idColumnName] as String,
      characterId: map[Todo.characterIdColumnName] as String,
      name: map[Todo.nameColumnName] as String,
      description: map[Todo.descriptionColumnName] as String,
      difficulty: DifficultyLevel.values[map[Todo.difficultyColumnName] as int],
      priority: PriorityLevel.values[map[Todo.priorityColumnName] as int],
      dueDate: map[Todo.dueDateColumnName] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map[Todo.dueDateColumnName] as int)
          : null,
      hasTime: map[Todo.hasTimeColumnName] == 1,
      isCompleted: map[Todo.isCompletedColumnName] == 1,
      tags: tags,
      reminders: reminders,
    );
  }

  // GET tags for todo
  Future<List<Tag>> _getTagsForTodo(String id) async {
    // Get TodoTags
    final todoTagsMaps = await db.query(TodoTag.todoTagTableName,
        where: '${TodoTag.todoIdColumnName} = ?', whereArgs: [id]);
    final todoTags = todoTagsMaps.map(
      (map) => TodoTag(
        id: map[TodoTag.idColumnName] as String,
        todoId: map[TodoTag.todoIdColumnName] as String,
        characterTagId: map[TodoTag.characterTagIdColumnName] as String,
      ),
    );

    // Get Tags from CharacterTags
    final characterTagsMaps = await db.query(CharacterTag.characterTagTableName,
        where:
            '${CharacterTag.idColumnName} IN (${List.filled(todoTags.length, '?').join(',')})',
        whereArgs: todoTags.map((tag) => tag.characterTagId).toList());
    final tags = characterTagsMaps.map(
      (map) => Tag(
        characterTagId: map[CharacterTag.idColumnName] as String,
        name: map[CharacterTag.nameColumnName] as String,
        colorIndex: map[CharacterTag.colorIndexColumnName] as int,
        iconIndex: map[CharacterTag.iconIndexColumnName] as int,
      ),
    );
    return tags.toList();
  }

  // GET reminders for todo
  Future<List<TodoReminder>> getRemindersForTodo(String todoId) async {
    final reminders = await db.query(TodoReminder.todoReminderTableName,
        where: '${TodoReminder.todoIdColumnName} = ?', whereArgs: [todoId]);
    return reminders.map((map) => _getReminderFromMap(map)).toList();
  }

  // UPDATE reminder
  Future<void> updateReminder(TodoReminder reminder) async {
    await db.update(TodoReminder.todoReminderTableName, reminder.toMap(),
        where: '${TodoReminder.idColumnName} = ?', whereArgs: [reminder.id]);
  }

  // DELETE reminder
  Future<void> deleteReminder(TodoReminder reminder) async {
    await db.delete(TodoReminder.todoReminderTableName,
        where: '${TodoReminder.idColumnName} = ?', whereArgs: [reminder.id]);
  }

  // INSERT reminder
  Future<void> createReminder(TodoReminder reminder) async {
    await db.insert(TodoReminder.todoReminderTableName, reminder.toMap());
  }

  // GET reminder from map
  TodoReminder _getReminderFromMap(Map<String, dynamic> map) {
    return TodoReminder(
      id: map[TodoReminder.idColumnName] as String,
      todoId: map[TodoReminder.todoIdColumnName] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
          map[TodoReminder.dateTimeColumnName] as int),
    );
  }

  // GET reminders for todo
  Future<List<TodoReminder>> _getRemindersForTodo(String todoId) async {
    final reminders = await db.query(TodoReminder.todoReminderTableName,
        where: '${TodoReminder.todoIdColumnName} = ?', whereArgs: [todoId]);
    return reminders.map((map) => _getReminderFromMap(map)).toList();
  }
}
