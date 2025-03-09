import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/add_todo/add_todo_state.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:uuid/uuid.dart';

class AddTodoCubit extends Cubit<AddTodoState> {
  final TodoRepository todoRepository;

  AddTodoCubit(this.todoRepository)
      : super(AddTodoState(id: const Uuid().v4()));

  void nameChanged(String value) {
    emit(state.copyWith(name: value));
  }

  void descriptionChanged(String value) {
    emit(state.copyWith(description: value));
  }

  void dueDateChanged(String value) {
    emit(state.copyWith(dueDate: value));
  }

  void difficultyChanged(int value) {
    emit(state.copyWith(difficulty: value));
  }

  Future<void> submit() async {
    emit(state.copyWith(status: AddTodoStatus.loading));

    try {
      final todo = Todo(
        id: state.id,
        name: state.name,
        description: state.description,
        dueDate: state.dueDate,
        difficulty: state.difficulty,
        isCompleted: false,
      );

      await todoRepository.createTodo(todo);
      emit(state.copyWith(
        status: AddTodoStatus.initial,
        id: const Uuid().v4(),
        name: '',
        description: '',
        dueDate: '',
        difficulty: 1,
      ));
    } catch (e) {
      // Handle error
      emit(state.copyWith(status: AddTodoStatus.initial));
    }
  }
}
