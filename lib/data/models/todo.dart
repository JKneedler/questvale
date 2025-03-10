import 'package:flutter/material.dart';
import 'package:questvale/data/models/tag.dart';

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
        return Colors.grey;
      case DifficultyLevel.easy:
        return Color(0xFFCD7F32); // Bronze
      case DifficultyLevel.medium:
        return Color(0xFFC0C0C0); // Silver
      case DifficultyLevel.hard:
        return Color(0xFFFFD700); // Gold
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
        return Colors.grey;
      case PriorityLevel.low:
        return Color(0xFF00BFFF); // Light Blue
      case PriorityLevel.medium:
        return Color(0xFFFFA500); // Orange
      case PriorityLevel.high:
        return Color(0xFFDC143C); // Red
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

  static const createTableSQL = '''
		CREATE TABLE ${Todo.todoTableName}(
			${Todo.idColumnName} VARCHAR PRIMARY KEY, 
			${Todo.characterIdColumnName} VARCHAR NOT NULL, 
			${Todo.nameColumnName} VARCHAR NOT NULL, 
			${Todo.descriptionColumnName} VARCHAR, 
			${Todo.isCompletedColumnName} BOOLEAN,
			${Todo.difficultyColumnName} INTEGER,
			${Todo.priorityColumnName} INTEGER,
			${Todo.dueDateColumnName} VARCHAR
		);
	''';

  final String id;
  final String characterId;
  final String name;
  final String description;
  final bool isCompleted;
  final DifficultyLevel difficulty;
  final PriorityLevel priority;
  final String dueDate;
  final List<Tag> tags;

  const Todo({
    required this.id,
    required this.characterId,
    required this.name,
    required this.description,
    required this.isCompleted,
    required this.difficulty,
    required this.priority,
    required this.dueDate,
    required this.tags,
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
      Todo.dueDateColumnName: dueDate,
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
				tags: $tags
			}''';
  }

  Todo copyWith({
    String? name,
    String? description,
    bool? isCompleted,
    DifficultyLevel? difficulty,
    PriorityLevel? priority,
    String? dueDate,
    List<Tag>? tags,
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
      tags: tags ?? this.tags,
    );
  }
}
