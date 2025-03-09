import 'package:questvale/data/models/todo.dart';
import 'package:sqflite/sqflite.dart';

class TodoRepository {
  final Database db;

  TodoRepository({required this.db}) {
    logTodos();
  }

  // GET all todos
  Future<List<Todo>> getTodos() async {
    final List<Map<String, dynamic>> maps = await db.query(Todo.todoTableName);
    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i][Todo.idColumnName] as String,
        name: maps[i][Todo.nameColumnName] as String,
        description: maps[i][Todo.descriptionColumnName] as String,
        difficulty: maps[i][Todo.difficultyColumnName] as int,
        dueDate: maps[i][Todo.dueDateColumnName] as String? ?? '',
        isCompleted: maps[i][Todo.isCompletedColumnName] == 1,
      );
    });
  }

  // GET todo by id
  Future<Todo> getTodoById(String id) async {
    final todos = await db.query(Todo.todoTableName,
        where: '${Todo.idColumnName} = ?', whereArgs: [id], limit: 1);
    return Todo(
      id: todos[0][Todo.idColumnName] as String,
      name: todos[0][Todo.nameColumnName] as String,
      description: todos[0][Todo.descriptionColumnName] as String,
      difficulty: todos[0][Todo.difficultyColumnName] as int,
      dueDate: todos[0][Todo.dueDateColumnName] as String? ?? '',
      isCompleted: (todos[0][Todo.isCompletedColumnName] as int) == 1,
    );
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
  }
}
