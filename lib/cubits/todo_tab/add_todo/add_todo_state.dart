import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/todo.dart';

enum AddTodoStatus { initial, loading, done }

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

class AddTodoState extends Equatable {
  final AddTodoStatus status;
  final String characterId;
  final String id;
  final String name;
  final String description;
  final DateTime? dueDate;
  final bool hasTime;
  final DifficultyLevel difficulty;
  final PriorityLevel priority;
  final List<Tag> availableTags;
  final List<Tag> selectedTags;
  final List<ReminderType> reminders;

  const AddTodoState({
    this.status = AddTodoStatus.initial,
    required this.characterId,
    required this.id,
    this.name = '',
    this.description = '',
    this.dueDate,
    this.hasTime = false,
    this.difficulty = DifficultyLevel.trivial,
    this.priority = PriorityLevel.noPriority,
    this.availableTags = const [],
    this.selectedTags = const [],
    this.reminders = const [],
  });

  AddTodoState copyWith({
    AddTodoStatus? status,
    String? characterId,
    String? id,
    String? name,
    String? description,
    DateTime? dueDate,
    bool? hasTime,
    DifficultyLevel? difficulty,
    PriorityLevel? priority,
    List<Tag>? availableTags,
    List<Tag>? selectedTags,
    List<ReminderType>? reminders,
  }) {
    return AddTodoState(
      status: status ?? this.status,
      characterId: characterId ?? this.characterId,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      hasTime: hasTime ?? this.hasTime,
      difficulty: difficulty ?? this.difficulty,
      priority: priority ?? this.priority,
      availableTags: availableTags ?? this.availableTags,
      selectedTags: selectedTags ?? this.selectedTags,
      reminders: reminders ?? this.reminders,
    );
  }

  @override
  List<Object?> get props => [
        status,
        characterId,
        id,
        name,
        description,
        hasTime,
        dueDate,
        difficulty,
        priority,
        availableTags,
        selectedTags,
        reminders,
      ];
}
