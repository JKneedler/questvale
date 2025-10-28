import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/tag.dart';

class TodosOverviewState extends Equatable {
  final Character? character;
  final List<Todo> todos;
  final List<Tag> availableTags;

  const TodosOverviewState({
    this.character,
    this.todos = const [],
    this.availableTags = const [],
  });

  TodosOverviewState copyWith({
    Character? character,
    List<Todo>? todos,
    List<Tag>? availableTags,
  }) {
    return TodosOverviewState(
      character: character ?? this.character,
      todos: todos ?? this.todos,
      availableTags: availableTags ?? this.availableTags,
    );
  }

  @override
  List<Object> get props => [todos, availableTags, character ?? ''];
}
