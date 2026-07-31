import 'package:flutter/material.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/todo_reminder.dart';
import 'package:questvale/helpers/constants.dart';

enum DifficultyLevel {
  trivial,
  easy,
  medium,
  hard;

  String get name {
    switch (this) {
      case DifficultyLevel.trivial:
        return 'Trivial';
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  Color get color {
    switch (this) {
      case DifficultyLevel.trivial:
        return DIFFICULTY_TRIVIAL_COLOR;
      case DifficultyLevel.easy:
        return DIFFICULTY_EASY_COLOR;
      case DifficultyLevel.medium:
        return DIFFICULTY_MEDIUM_COLOR;
      case DifficultyLevel.hard:
        return DIFFICULTY_HARD_COLOR;
    }
  }
}

enum HabitTimeframe {
  daily,
  weekly,
  monthly;

  String get name {
    switch (this) {
      case HabitTimeframe.daily:
        return 'Daily';
      case HabitTimeframe.weekly:
        return 'Weekly';
      case HabitTimeframe.monthly:
        return 'Monthly';
    }
  }
}

enum PriorityLevel {
  noPriority,
  low,
  medium,
  high;

  String get name {
    switch (this) {
      case PriorityLevel.noPriority:
        return 'No Priority';
      case PriorityLevel.low:
        return 'Low Priority';
      case PriorityLevel.medium:
        return 'Medium Priority';
      case PriorityLevel.high:
        return 'High Priority';
    }
  }

  Color get color {
    switch (this) {
      case PriorityLevel.noPriority:
        return PRIORITY_NONE_COLOR;
      case PriorityLevel.low:
        return PRIORITY_LOW_COLOR;
      case PriorityLevel.medium:
        return PRIORITY_MEDIUM_COLOR;
      case PriorityLevel.high:
        return PRIORITY_HIGH_COLOR;
    }
  }
}

class Todo {
  static const todoTableName = 'Todos';

  static const idColumnName = 'id';
  static const characterIdColumnName = 'characterId';
  static const nameColumnName = 'name';
  static const descriptionColumnName = 'description';
  static const isCompletedColumnName = 'isCompleted';
  static const difficultyColumnName = 'difficulty';
  static const priorityColumnName = 'priority';
  static const dueDateColumnName = 'dueDate';
  static const hasTimeColumnName = 'hasTime';
  static const isHabitColumnName = 'isHabit';
  static const timeframeColumnName = 'timeframe';
  static const allowsMultipleCompletionsColumnName =
      'allowsMultipleCompletions';
  static const completionsInCurrentPeriodColumnName =
      'completionsInCurrentPeriod';
  static const currentStreakColumnName = 'currentStreak';
  static const currentPeriodStartColumnName = 'currentPeriodStart';
  static const completionAwardedColumnName = 'completionAwarded';

  static const createTableSQL = '''
		CREATE TABLE ${Todo.todoTableName}(
			${Todo.idColumnName} VARCHAR PRIMARY KEY,
			${Todo.characterIdColumnName} VARCHAR NOT NULL,
			${Todo.nameColumnName} VARCHAR NOT NULL,
			${Todo.descriptionColumnName} VARCHAR,
			${Todo.isCompletedColumnName} BOOLEAN,
			${Todo.difficultyColumnName} INTEGER,
			${Todo.priorityColumnName} INTEGER,
			${Todo.dueDateColumnName} INTEGER,
			${Todo.hasTimeColumnName} BOOLEAN,
			${Todo.isHabitColumnName} BOOLEAN DEFAULT 0,
			${Todo.timeframeColumnName} INTEGER,
			${Todo.allowsMultipleCompletionsColumnName} BOOLEAN DEFAULT 0,
			${Todo.completionsInCurrentPeriodColumnName} INTEGER DEFAULT 0,
			${Todo.currentStreakColumnName} INTEGER DEFAULT 0,
			${Todo.currentPeriodStartColumnName} INTEGER,
			${Todo.completionAwardedColumnName} BOOLEAN DEFAULT 0
		);
	''';

  final String id;
  final String characterId;
  final String name;
  final String description;
  final bool isCompleted;
  final DifficultyLevel difficulty;
  final PriorityLevel priority;
  final DateTime? dueDate;
  final bool hasTime;
  final List<Tag> tags;
  final List<TodoReminder> reminders;
  final bool isHabit;
  final HabitTimeframe? timeframe;
  final bool allowsMultipleCompletions;
  final int completionsInCurrentPeriod;
  final int currentStreak;
  final DateTime? currentPeriodStart;
  // Has this item's current single-check completion already earned its
  // AP + stats credit? Prevents un-completing and re-completing to farm
  // either one repeatedly. Not used for multi-check habits, where every
  // completion is genuinely new.
  final bool completionAwarded;

  const Todo({
    required this.id,
    required this.characterId,
    required this.name,
    required this.description,
    required this.isCompleted,
    required this.difficulty,
    required this.priority,
    required this.dueDate,
    required this.hasTime,
    required this.tags,
    required this.reminders,
    this.isHabit = false,
    this.timeframe,
    this.allowsMultipleCompletions = false,
    this.completionsInCurrentPeriod = 0,
    this.currentStreak = 0,
    this.currentPeriodStart,
    this.completionAwarded = false,
  });

  Map<String, Object?> toMap() {
    return {
      Todo.idColumnName: id,
      Todo.characterIdColumnName: characterId,
      Todo.nameColumnName: name,
      Todo.descriptionColumnName: description,
      Todo.isCompletedColumnName: isCompleted ? 1 : 0,
      Todo.difficultyColumnName: difficulty.index,
      Todo.priorityColumnName: priority.index,
      Todo.dueDateColumnName: dueDate?.millisecondsSinceEpoch,
      Todo.hasTimeColumnName: hasTime ? 1 : 0,
      Todo.isHabitColumnName: isHabit ? 1 : 0,
      Todo.timeframeColumnName: timeframe?.index,
      Todo.allowsMultipleCompletionsColumnName:
          allowsMultipleCompletions ? 1 : 0,
      Todo.completionsInCurrentPeriodColumnName: completionsInCurrentPeriod,
      Todo.currentStreakColumnName: currentStreak,
      Todo.currentPeriodStartColumnName:
          currentPeriodStart?.millisecondsSinceEpoch,
      Todo.completionAwardedColumnName: completionAwarded ? 1 : 0,
    };
  }

  @override
  String toString() {
    return '''Todo {
				id: $id
				name: $name
				description: $description
				isCompleted: $isCompleted
				difficulty: $difficulty
				dueDate: $dueDate
				hasTime: $hasTime
				tags: $tags
				reminders: $reminders
			}''';
  }

  Todo copyWith({
    String? name,
    String? description,
    bool? isCompleted,
    DifficultyLevel? difficulty,
    PriorityLevel? priority,
    DateTime? dueDate,
    bool? hasTime,
    List<Tag>? tags,
    List<TodoReminder>? reminders,
    bool? isHabit,
    HabitTimeframe? timeframe,
    bool? allowsMultipleCompletions,
    int? completionsInCurrentPeriod,
    int? currentStreak,
    DateTime? currentPeriodStart,
    bool? completionAwarded,
  }) {
    return Todo(
      id: id,
      characterId: characterId,
      name: name ?? this.name,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      difficulty: difficulty ?? this.difficulty,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      hasTime: hasTime ?? this.hasTime,
      tags: tags ?? this.tags,
      reminders: reminders ?? this.reminders,
      isHabit: isHabit ?? this.isHabit,
      timeframe: timeframe ?? this.timeframe,
      allowsMultipleCompletions:
          allowsMultipleCompletions ?? this.allowsMultipleCompletions,
      completionsInCurrentPeriod:
          completionsInCurrentPeriod ?? this.completionsInCurrentPeriod,
      currentStreak: currentStreak ?? this.currentStreak,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      completionAwarded: completionAwarded ?? this.completionAwarded,
    );
  }
}
