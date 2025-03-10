import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/todo_tag.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class TodoRepository {
  final Database db;

  TodoRepository({required this.db}) {
    logTodos();
  }

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

  // ADD todo
  Future<void> addTodo(Todo addTodo) async {
    await db.insert(Todo.todoTableName, addTodo.toMap());
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

  Future<void> logTodos() async {
    final todoMaps = await db.query(Todo.todoTableName);
    print('Todos:');
    for (final todoMap in todoMaps) {
      print(todoMap);
    }
  }

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
  }

  Future<Todo> _getTodoFromMap(Map<String, dynamic> map) async {
    final tags = await _getTagsForTodo(map[Todo.idColumnName] as String);
    return Todo(
      id: map[Todo.idColumnName] as String,
      characterId: map[Todo.characterIdColumnName] as String,
      name: map[Todo.nameColumnName] as String,
      description: map[Todo.descriptionColumnName] as String,
      difficulty: DifficultyLevel.values[map[Todo.difficultyColumnName] as int],
      priority: PriorityLevel.values[map[Todo.priorityColumnName] as int],
      dueDate: map[Todo.dueDateColumnName] as String? ?? '',
      hasTime: map[Todo.hasTimeColumnName] == 1,
      isCompleted: map[Todo.isCompletedColumnName] == 1,
      tags: tags,
    );
  }

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
}
