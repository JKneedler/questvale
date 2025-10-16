import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todos_overview/todos_overview_state.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:questvale/data/repositories/character_repository.dart';

class TodosOverviewCubit extends Cubit<TodosOverviewState> {
  final TodoRepository todoRepository;
  final CharacterRepository characterRepository;

  TodosOverviewCubit(this.todoRepository, this.characterRepository)
      : super(const TodosOverviewState()) {
    loadCharacter();
  }

  Future<void> loadCharacter() async {
    final character = await characterRepository.getSingleCharacter();
    final todos = await todoRepository.getTodosByCharacterId(character.id);
    final availableTags =
        await characterRepository.getCharacterTags(character.id);
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

  Future<void> toggleCompletion(Todo todo) async {
    await todoRepository.updateTodo(
      todo.copyWith(isCompleted: !todo.isCompleted),
    );
    await loadCharacter();
  }

  Future<void> deleteTodo(Todo todo) async {
    await todoRepository.deleteTodo(todo);
    await loadCharacter();
  }
}
