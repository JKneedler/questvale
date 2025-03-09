import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/todo.dart';

class TodosOverviewState extends Equatable {
  final List<Todo> todos;

  const TodosOverviewState({
    this.todos = const [],
  });

  TodosOverviewState copyWith({
    List<Todo>? todos,
  }) {
    return TodosOverviewState(
      todos: todos ?? this.todos,
    );
  }

  @override
  List<Object> get props => [todos];
}
