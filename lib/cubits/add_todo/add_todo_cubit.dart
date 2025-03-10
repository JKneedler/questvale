import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/add_todo/add_todo_state.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:uuid/uuid.dart';

class AddTodoCubit extends Cubit<AddTodoState> {
  final TodoRepository todoRepository;
  final CharacterRepository characterRepository;
  final String characterId;

  AddTodoCubit(this.todoRepository, this.characterRepository, this.characterId)
      : super(AddTodoState(
          id: const Uuid().v4(),
          characterId: characterId,
        )) {
    loadAvailableTags();
  }

  Future<void> loadAvailableTags() async {
    final availableTags =
        await characterRepository.getCharacterTags(characterId);
    emit(
      state.copyWith(
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

  void nameChanged(String value) {
    emit(state.copyWith(name: value));
  }

  void descriptionChanged(String value) {
    emit(state.copyWith(description: value));
  }

  void dueDateChanged(DateTime? date, bool hasTime) {
    emit(AddTodoState(
      id: state.id,
      characterId: state.characterId,
      name: state.name,
      description: state.description,
      dueDate: date,
      hasTime: hasTime,
      difficulty: state.difficulty,
      priority: state.priority,
      availableTags: state.availableTags,
      selectedTags: state.selectedTags,
      status: AddTodoStatus.initial,
    ));
  }

  void difficultyChanged(DifficultyLevel value) {
    emit(state.copyWith(difficulty: value));
  }

  void priorityChanged(PriorityLevel value) {
    emit(state.copyWith(priority: value));
  }

  void toggleTag(Tag tag) {
    if (state.selectedTags.contains(tag)) {
      emit(state.copyWith(
          selectedTags: state.selectedTags.where((t) => t != tag).toList()));
    } else {
      emit(state.copyWith(selectedTags: [...state.selectedTags, tag]));
    }
  }

  Future<void> submit() async {
    emit(state.copyWith(status: AddTodoStatus.loading));

    try {
      final todo = Todo(
        id: state.id,
        characterId: characterId,
        name: state.name,
        description: state.description,
        dueDate: state.dueDate != null ? state.dueDate!.toIso8601String() : '',
        difficulty: state.difficulty,
        priority: state.priority,
        isCompleted: false,
        tags: state.selectedTags,
        hasTime: state.hasTime,
      );

      await todoRepository.createTodo(todo);
      emit(AddTodoState(
        status: AddTodoStatus.initial,
        id: const Uuid().v4(),
        characterId: characterId,
        name: '',
        description: '',
        dueDate: null,
        hasTime: false,
        difficulty: DifficultyLevel.trivial,
        priority: PriorityLevel.noPriority,
        selectedTags: [],
      ));
    } catch (e) {
      // Handle error
      emit(state.copyWith(status: AddTodoStatus.initial));
    }
  }
}
