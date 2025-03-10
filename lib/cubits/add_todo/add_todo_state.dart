import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/todo.dart';

enum AddTodoStatus { initial, loading, done }

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
      ];
}
