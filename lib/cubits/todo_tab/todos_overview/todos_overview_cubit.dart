import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_state.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/services/ap_reward_service.dart';
import 'package:questvale/services/habit_service.dart';

class TodosOverviewCubit extends Cubit<TodosOverviewState> {
  final TodoRepository todoRepository;
  final CharacterRepository characterRepository;
  final PlayerCubit playerCubit;
  late final HabitService habitService;
  late final ApRewardService apRewardService;

  TodosOverviewCubit(this.todoRepository, this.characterRepository,
      GameData gameData, this.playerCubit)
      : super(const TodosOverviewState()) {
    habitService = HabitService();
    apRewardService = ApRewardService(gameData: gameData);
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

  // Tasks stay freely completable/uncompletable — they just only ever earn
  // AP once (apAwarded latches true and never resets for a one-time Task).
  Future<void> toggleCompletion(Todo todo) async {
    final isCompleting = !todo.isCompleted;

    bool apAwarded = todo.apAwarded;
    if (isCompleting && !todo.apAwarded) {
      final awarded = await _awardAp(todo.difficulty, isHabit: false);
      if (awarded) apAwarded = true;
    }

    await todoRepository.updateTodo(
      todo.copyWith(isCompleted: isCompleting, apAwarded: apAwarded),
    );
    await loadCharacter();
  }

  Future<void> completeHabitOnce(Todo todo) async {
    final result = habitService.completeOnce(todo);
    if (!result.isNewCompletion) {
      await todoRepository.updateTodo(result.updated);
      await loadCharacter();
      return;
    }

    // Multi-check habits earn AP every tap by design (each one is a
    // genuinely new completion). Single-check habits toggle like a Task,
    // so they get the same "only the first time" guard.
    bool apAwarded = result.updated.apAwarded;
    if (todo.allowsMultipleCompletions || !todo.apAwarded) {
      final awarded = await _awardAp(todo.difficulty, isHabit: true);
      if (awarded && !todo.allowsMultipleCompletions) {
        apAwarded = true;
      }
    }

    await todoRepository.updateTodo(result.updated.copyWith(
      apAwarded: apAwarded,
    ));
    await loadCharacter();
  }

  // Returns whether AP was actually awarded (false if blocked by the daily
  // cap) so callers can decide whether to latch apAwarded.
  Future<bool> _awardAp(DifficultyLevel difficulty,
      {required bool isHabit}) async {
    final character = state.character;
    if (character == null) return false;

    final dailyEarned = apRewardService.currentDailyEarned(character);
    final rawAmount = apRewardService.apForCompletion(difficulty, isHabit);
    final awarded = apRewardService.applyDailyCap(dailyEarned, rawAmount);
    if (awarded <= 0) return false;

    final today = DateTime.now();
    await characterRepository.updateCharacter(character.copyWith(
      actionPoints: character.actionPoints + awarded,
      dailyApEarned: dailyEarned + awarded,
      dailyApEarnedDate: DateTime(today.year, today.month, today.day),
    ));
    // PlayerCubit holds the canonical Character used elsewhere (e.g.
    // world_tab's combat AP display) — it has its own separate in-memory
    // copy, so it won't pick up this change until told to reload.
    await playerCubit.loadCharacter();
    return true;
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
