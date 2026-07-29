import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_state.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/services/habit_service.dart';

class TodosOverviewCubit extends Cubit<TodosOverviewState> {
  final TodoRepository todoRepository;
  final CharacterRepository characterRepository;
  late final HabitService habitService;

  TodosOverviewCubit(this.todoRepository, this.characterRepository)
      : super(const TodosOverviewState()) {
    habitService = HabitService(todoRepository: todoRepository);
    loadCharacter();
  }

  Future<void> loadCharacter() async {
    final character = await characterRepository.getSingleCharacter();
    final todos = await todoRepository.getTodosByCharacterId(character.id);
    final availableTags =
        await characterRepository.getCharacterTags(character.id);
    if (!isClosed) {
      emit(
        state.copyWith(
          character: character,
          todos: todos,
          availableTags: availableTags
              .map((tag) => Tag(
                    characterTagId: tag.id,
                    name: tag.name,
                    colorIndex: tag.colorIndex,
                    iconIndex: tag.iconIndex,
                  ))
              .toList(),
        ),
      );
    }
  }

  Future<void> toggleCompletion(Todo todo) async {
    await todoRepository.updateTodo(
      todo.copyWith(isCompleted: !todo.isCompleted),
    );
    await loadCharacter();
  }

  Future<void> completeHabitOnce(Todo todo) async {
    await habitService.completeOnce(todo);
    await loadCharacter();
  }

  Future<void> deleteTodo(Todo todo) async {
    await todoRepository.deleteTodo(todo);
    await loadCharacter();
  }

  void setFilter(TodoFilter filter, {Tag? tag, PriorityLevel? priority}) {
    emit(TodosOverviewState(
      character: state.character,
      todos: state.todos,
      availableTags: state.availableTags,
      filter: filter,
      filterTag: filter == TodoFilter.byTag ? tag : null,
      filterPriority: filter == TodoFilter.byPriority ? priority : null,
      sort: state.sort,
    ));
  }

  void setSort(TodoSort sort) {
    emit(state.copyWith(sort: sort));
  }

  void setViewMode(TodosViewMode viewMode) {
    emit(state.copyWith(viewMode: viewMode));
  }
}
