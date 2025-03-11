class TodoReminder {
  static const todoReminderTableName = 'TodoReminders';

  static const idColumnName = 'id';
  static const todoIdColumnName = 'todoId';
  static const dateTimeColumnName = 'dateTime';

  static const createTableSQL = '''
    CREATE TABLE ${TodoReminder.todoReminderTableName}(
      ${TodoReminder.idColumnName} VARCHAR PRIMARY KEY,
      ${TodoReminder.todoIdColumnName} VARCHAR NOT NULL,
      ${TodoReminder.dateTimeColumnName} INTEGER NOT NULL
    );
  ''';

  final String id;
  final String todoId;
  final DateTime dateTime;

  const TodoReminder({
    required this.id,
    required this.todoId,
    required this.dateTime,
  });

  Map<String, Object?> toMap() {
    return {
      TodoReminder.idColumnName: id,
      TodoReminder.todoIdColumnName: todoId,
      TodoReminder.dateTimeColumnName: dateTime.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'TodoReminder(id: $id, todoId: $todoId, dateTime: $dateTime)';
  }

  TodoReminder copyWith({
    String? id,
    String? todoId,
    DateTime? dateTime,
  }) {
    return TodoReminder(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
