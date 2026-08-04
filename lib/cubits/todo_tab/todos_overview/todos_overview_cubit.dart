import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_state.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/services/ap_reward_service.dart';
import 'package:questvale/services/habit_service.dart';
import 'package:questvale/services/notification_service.dart';

class TodosOverviewCubit extends Cubit<TodosOverviewState> {
  final TodoRepository todoRepository;
  final CharacterRepository characterRepository;
  final QuestRepository questRepository;
  final EncounterRepository encounterRepository;
  final GameData gameData;
  final PlayerCubit playerCubit;
  late final HabitService habitService;
  late final ApRewardService apRewardService;

  TodosOverviewCubit(
      this.todoRepository,
      this.characterRepository,
      this.questRepository,
      this.encounterRepository,
      this.gameData,
      this.playerCubit)
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

    final quest = await questRepository.getQuest(character.id);
    final encounter = quest != null && quest.completedAt == null
        ? await encounterRepository.getEncounterByQuestId(quest.id)
        : null;
    final questZone = quest != null
        ? gameData.questZones.firstWhereOrNull((z) => z.id == quest.zoneId)
        : null;

    if (!isClosed) {
      emit(
        TodosOverviewState(
          character: character,
          characterStats: stats,
          todos: todos,
          availableTags: availableTags
              .map((tag) => Tag(
                    characterTagId: tag.id,
                    name: tag.name,
                  ))
              .toList(),
          filter: state.filter,
          filterTag: state.filterTag,
          filterPriority: state.filterPriority,
          sort: state.sort,
          viewMode: state.viewMode,
          activeEncounter: encounter,
          activeQuestZone: questZone,
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
  Future<int> toggleCompletion(Todo todo) async {
    final isCompleting = !todo.isCompleted;

    bool completionAwarded = todo.completionAwarded;
    int apEarned = 0;
    if (isCompleting && !todo.completionAwarded) {
      apEarned = await _grantCompletionRewards(todo.difficulty, isHabit: false);
      if (apEarned > 0) completionAwarded = true;
    }

    await todoRepository.updateTodo(
      todo.copyWith(
          isCompleted: isCompleting, completionAwarded: completionAwarded),
    );
    await loadCharacter();
    return apEarned;
  }

  Future<int> completeHabitOnce(Todo todo) async {
    final result = habitService.completeOnce(todo);
    if (!result.isNewCompletion) {
      await todoRepository.updateTodo(result.updated);
      await loadCharacter();
      return 0;
    }

    // Multi-check habits earn AP + stats credit every tap by design (each
    // one is a genuinely new completion). Single-check habits toggle like
    // a Task, so they get the same "only the first time" guard.
    bool completionAwarded = result.updated.completionAwarded;
    int apEarned = 0;
    if (todo.allowsMultipleCompletions || !todo.completionAwarded) {
      apEarned = await _grantCompletionRewards(todo.difficulty, isHabit: true);
      if (apEarned > 0 && !todo.allowsMultipleCompletions) {
        completionAwarded = true;
      }
    }

    await todoRepository.updateTodo(result.updated.copyWith(
      completionAwarded: completionAwarded,
    ));
    await loadCharacter();
    return apEarned;
  }

  // Grants AP (subject to the daily cap) and increments the totalCompleted
  // stat together, as one bundled reward — callers gate repeat calls behind
  // completionAwarded so re-toggling can't farm either one. Returns the AP
  // amount actually granted (0 if blocked by the daily cap or the character
  // isn't in combat — no AP outside combat, regardless of what the caller's
  // own UI already confirmed with the player), so callers can decide
  // whether to latch completionAwarded and whether to show feedback.
  Future<int> _grantCompletionRewards(DifficultyLevel difficulty,
      {required bool isHabit}) async {
    final character = state.character;
    final stats = state.characterStats;
    if (character == null || stats == null) return 0;
    if (!state.isInActiveCombat) return 0;

    final dailyEarned = apRewardService.currentDailyEarned(character);
    final rawAmount = apRewardService.apForCompletion(difficulty, isHabit);
    final awarded = apRewardService.applyDailyCap(dailyEarned, rawAmount);
    if (awarded <= 0) return 0;

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
    return awarded;
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
      activeEncounter: state.activeEncounter,
      activeQuestZone: state.activeQuestZone,
    ));
  }

  void setSort(TodoSort sort) {
    emit(state.copyWith(sort: sort));
  }

  void setViewMode(TodosViewMode viewMode) {
    emit(state.copyWith(viewMode: viewMode));
  }
}
