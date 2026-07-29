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
import 'package:questvale/services/notification_service.dart';

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
    var stats = await characterRepository.getCharacterStats(character.id);
    var todos = await todoRepository.getTodosByCharacterId(character.id);
    todos = await Future.wait(todos.map(_advanceHabitPeriodIfNeeded));

    // Stats tracking: longest streak ever achieved across all habits, kept
    // in sync whenever a period rollover changes a streak.
    final bestStreak = todos.fold<int>(0,
        (best, todo) => todo.currentStreak > best ? todo.currentStreak : best);
    if (bestStreak > stats.longestStreakAchieved) {
      stats = stats.copyWith(longestStreakAchieved: bestStreak);
      await characterRepository.updateCharacterStats(stats);
    }

    final availableTags =
        await characterRepository.getCharacterTags(character.id);
    if (!isClosed) {
      emit(
        state.copyWith(
          character: character,
          characterStats: stats,
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

  // Checked on every load rather than on a timer/background job — cheap,
  // idempotent (no-ops if no period has elapsed), and keeps streaks correct
  // even if the app wasn't opened during the period boundary.
  Future<Todo> _advanceHabitPeriodIfNeeded(Todo todo) async {
    final updated = habitService.advancePeriodsIfNeeded(todo);
    if (identical(updated, todo)) return todo;
    await todoRepository.updateTodo(updated);
    return updated;
  }

  // Tasks stay freely completable/uncompletable — they just only ever earn
  // AP + stats credit once (completionAwarded latches true and never resets
  // for a one-time Task).
  Future<void> toggleCompletion(Todo todo) async {
    final isCompleting = !todo.isCompleted;

    bool completionAwarded = todo.completionAwarded;
    if (isCompleting && !todo.completionAwarded) {
      final rewarded =
          await _grantCompletionRewards(todo.difficulty, isHabit: false);
      if (rewarded) completionAwarded = true;
    }

    await todoRepository.updateTodo(
      todo.copyWith(
          isCompleted: isCompleting, completionAwarded: completionAwarded),
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

    // Multi-check habits earn AP + stats credit every tap by design (each
    // one is a genuinely new completion). Single-check habits toggle like
    // a Task, so they get the same "only the first time" guard.
    bool completionAwarded = result.updated.completionAwarded;
    if (todo.allowsMultipleCompletions || !todo.completionAwarded) {
      final rewarded =
          await _grantCompletionRewards(todo.difficulty, isHabit: true);
      if (rewarded && !todo.allowsMultipleCompletions) {
        completionAwarded = true;
      }
    }

    await todoRepository.updateTodo(result.updated.copyWith(
      completionAwarded: completionAwarded,
    ));
    await loadCharacter();
  }

  // Grants AP (subject to the daily cap) and increments the totalCompleted
  // stat together, as one bundled reward — callers gate repeat calls behind
  // completionAwarded so re-toggling can't farm either one. Returns whether
  // the reward actually fired (false if blocked by the daily cap), so
  // callers can decide whether to latch completionAwarded.
  Future<bool> _grantCompletionRewards(DifficultyLevel difficulty,
      {required bool isHabit}) async {
    final character = state.character;
    final stats = state.characterStats;
    if (character == null || stats == null) return false;

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
    await characterRepository.updateCharacterStats(
      stats.copyWith(totalCompleted: stats.totalCompleted + 1),
    );
    // PlayerCubit holds the canonical Character used elsewhere (e.g.
    // world_tab's combat AP display) — it has its own separate in-memory
    // copy, so it won't pick up this change until told to reload.
    await playerCubit.loadCharacter();
    return true;
  }

  Future<void> deleteTodo(Todo todo) async {
    await todoRepository.deleteTodo(todo);
    for (final reminder in todo.reminders) {
      await NotificationService().cancelReminder(reminder.id);
    }
    await loadCharacter();
  }

  void setFilter(TodoFilter filter, {Tag? tag, PriorityLevel? priority}) {
    emit(TodosOverviewState(
      character: state.character,
      characterStats: state.characterStats,
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
