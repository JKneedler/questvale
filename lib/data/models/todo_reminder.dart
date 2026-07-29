enum ReminderType {
  atTimeWithoutTime,
  oneDayBeforeWithoutTime,
  twoDaysBeforeWithoutTime,
  threeDeysBeforeWithoutTime,
  oneWeekBeforeWithoutTime,
  atTimeWithTime,
  fiveMinutesBeforeWithTime,
  thirtyMinutesBeforeWithTime,
  oneHourBeforeWithTime,
  oneDayBeforeWithTime;

  String get name {
    switch (this) {
      case ReminderType.atTimeWithoutTime:
        return 'On time';
      case ReminderType.oneDayBeforeWithoutTime:
        return '1 day before';
      case ReminderType.twoDaysBeforeWithoutTime:
        return '2 days before';
      case ReminderType.threeDeysBeforeWithoutTime:
        return '3 days before';
      case ReminderType.oneWeekBeforeWithoutTime:
        return '1 week before';
      case ReminderType.atTimeWithTime:
        return 'On time';
      case ReminderType.fiveMinutesBeforeWithTime:
        return '5 minutes before';
      case ReminderType.thirtyMinutesBeforeWithTime:
        return '30 minutes before';
      case ReminderType.oneHourBeforeWithTime:
        return '1 hour before';
      case ReminderType.oneDayBeforeWithTime:
        return '1 day before';
    }
  }
}

class TodoReminder {
  static const todoReminderTableName = 'TodoReminders';

  static const idColumnName = 'id';
  static const todoIdColumnName = 'todoId';
  static const dateTimeColumnName = 'dateTime';
  static const reminderTypeColumnName = 'reminderType';

  static const createTableSQL = '''
    CREATE TABLE ${TodoReminder.todoReminderTableName}(
      ${TodoReminder.idColumnName} VARCHAR PRIMARY KEY,
      ${TodoReminder.todoIdColumnName} VARCHAR NOT NULL,
      ${TodoReminder.dateTimeColumnName} INTEGER NOT NULL,
      ${TodoReminder.reminderTypeColumnName} INTEGER
    );
  ''';

  final String id;
  final String todoId;
  final DateTime dateTime;
  final ReminderType? reminderType;

  const TodoReminder({
    required this.id,
    required this.todoId,
    required this.dateTime,
    this.reminderType,
  });

  Map<String, Object?> toMap() {
    return {
      TodoReminder.idColumnName: id,
      TodoReminder.todoIdColumnName: todoId,
      TodoReminder.dateTimeColumnName: dateTime.millisecondsSinceEpoch,
      TodoReminder.reminderTypeColumnName: reminderType?.index,
    };
  }

  @override
  String toString() {
    return 'TodoReminder(id: $id, todoId: $todoId, dateTime: $dateTime, '
        'reminderType: $reminderType)';
  }

  TodoReminder copyWith({
    String? id,
    String? todoId,
    DateTime? dateTime,
    ReminderType? reminderType,
  }) {
    return TodoReminder(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      dateTime: dateTime ?? this.dateTime,
      reminderType: reminderType ?? this.reminderType,
    );
  }
}
