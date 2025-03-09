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
  final String dueDate;
  final DifficultyLevel difficulty;
  final List<Tag> availableTags;
  final List<Tag> selectedTags;

  const AddTodoState({
    this.status = AddTodoStatus.initial,
    required this.characterId,
    required this.id,
    this.name = '',
    this.description = '',
    this.dueDate = '',
    this.difficulty = DifficultyLevel.trivial,
    this.availableTags = const [],
    this.selectedTags = const [],
  });

  AddTodoState copyWith({
    AddTodoStatus? status,
    String? characterId,
    String? id,
    String? name,
    String? description,
    String? dueDate,
    DifficultyLevel? difficulty,
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
      difficulty: difficulty ?? this.difficulty,
      availableTags: availableTags ?? this.availableTags,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }

  @override
  List<Object> get props => [
        status,
        characterId,
        id,
        name,
        description,
        dueDate,
        difficulty,
        availableTags,
        selectedTags,
      ];
}
