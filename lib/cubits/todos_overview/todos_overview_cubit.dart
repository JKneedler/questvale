import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todos_overview/todos_overview_state.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/repositories/todo_repository.dart';

class TodosOverviewCubit extends Cubit<TodosOverviewState> {
  final TodoRepository todoRepository;

  TodosOverviewCubit(this.todoRepository) : super(const TodosOverviewState()) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    final todos = await todoRepository.getTodos();
    emit(state.copyWith(todos: todos));
  }

  Future<void> toggleCompletion(Todo todo) async {
    await todoRepository.updateTodo(
      todo.copyWith(isCompleted: !todo.isCompleted),
    );
    await loadTodos();
  }

  Future<void> deleteTodo(Todo todo) async {
    await todoRepository.deleteTodo(todo);
    await loadTodos();
  }
}
