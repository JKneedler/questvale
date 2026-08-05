import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_stats.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/providers/game_data_models/enemy_data.dart';
import 'package:questvale/data/providers/game_data_models/quest_zone.dart';

enum TodoFilter {
  none,
  today,
  thisWeek,
  all,
  completed,
  byTag,
  byPriority;

  String get name {
    switch (this) {
      case TodoFilter.none:
        return 'None';
      case TodoFilter.today:
        return 'Today';
      case TodoFilter.thisWeek:
        return 'This Week';
      case TodoFilter.all:
        return 'All';
      case TodoFilter.completed:
        return 'Completed';
      case TodoFilter.byTag:
        return 'By Tag';
      case TodoFilter.byPriority:
        return 'By Priority';
    }
  }
}

enum TodoSort {
  dueDate,
  priority,
  difficulty,
  alphabetical;

  String get name {
    switch (this) {
      case TodoSort.dueDate:
        return 'Due Date';
      case TodoSort.priority:
        return 'Priority';
      case TodoSort.difficulty:
        return 'Difficulty';
      case TodoSort.alphabetical:
        return 'Alphabetical';
    }
  }
}

enum TodosViewMode { list, calendar }

class TodosOverviewState extends Equatable {
  final Character? character;
  final CharacterStats? characterStats;
  final List<Todo> todos;
  final List<Tag> availableTags;
  final TodoFilter filter;
  final Tag? filterTag;
  final PriorityLevel? filterPriority;
  final TodoSort sort;
  final TodosViewMode viewMode;

  // Null when the character has no in-progress quest/encounter — reflects
  // the real quest/encounter repositories, not a placeholder.
  final Encounter? activeEncounter;
  final QuestZone? activeQuestZone;

  const TodosOverviewState({
    this.character,
    this.characterStats,
    this.todos = const [],
    this.availableTags = const [],
    this.filter = TodoFilter.none,
    this.filterTag,
    this.filterPriority,
    this.sort = TodoSort.dueDate,
    this.viewMode = TodosViewMode.list,
    this.activeEncounter,
    this.activeQuestZone,
  });

  TodosOverviewState copyWith({
    Character? character,
    CharacterStats? characterStats,
    List<Todo>? todos,
    List<Tag>? availableTags,
    TodoSort? sort,
    TodosViewMode? viewMode,
  }) {
    return TodosOverviewState(
      character: character ?? this.character,
      characterStats: characterStats ?? this.characterStats,
      todos: todos ?? this.todos,
      availableTags: availableTags ?? this.availableTags,
      filter: filter,
      filterTag: filterTag,
      filterPriority: filterPriority,
      sort: sort ?? this.sort,
      viewMode: viewMode ?? this.viewMode,
      activeEncounter: activeEncounter,
      activeQuestZone: activeQuestZone,
    );
  }

  // Real check: mirrors the encounter-in-progress logic quest_encounter_cubit
  // already uses (combat-type encounter that hasn't been completed yet).
  bool get isInActiveCombat =>
      activeEncounter != null &&
      activeEncounter!.completedAt == null &&
      activeEncounter!.encounterType.isCombatEncounter();

  EnemyData? enemyDataFor(Enemy enemy) => activeQuestZone?.enemies
      .firstWhereOrNull((data) => data.id == enemy.enemyDataId);

  // "Today"/"This Week" are scoped by due date but don't hide completed
  // items — per the design, completion only dims a row; only the active
  // filter removes it from view. Habits and items with no due date are
  // always considered current, since they aren't tied to one calendar day.
  List<Todo> get visibleTodos {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));
    final endOfWeek = startOfToday.add(const Duration(days: 7));

    bool isDueWithin(Todo todo, DateTime start, DateTime end) {
      if (todo.isHabit) {
        // A weekly habit with specific weekdays selected only shows on
        // its actual occurrence days — but only under a single-day
        // window ("Today"). currentPeriodStart is the CURRENT (possibly
        // already-past-but-not-yet-elapsed) occurrence, so comparing it
        // against a week-long window here would incorrectly hide the
        // habit for the rest of the week the moment its day passes;
        // "This Week" instead keeps today's original always-visible
        // behavior for every habit configuration.
        final isSingleDayWindow = end.difference(start).inDays <= 1;
        if (isSingleDayWindow &&
            todo.timeframe == HabitTimeframe.weekly &&
            todo.repeatWeekdays.isNotEmpty) {
          final periodStart = todo.currentPeriodStart;
          if (periodStart == null) return true;
          return !periodStart.isBefore(start) && periodStart.isBefore(end);
        }
        return true;
      }
      if (todo.dueDate == null) return true;
      final dueDate = todo.dueDate!;
      return !dueDate.isBefore(start) && dueDate.isBefore(end);
    }

    Iterable<Todo> filtered;
    switch (filter) {
      case TodoFilter.none:
        filtered = todos.where((t) => !t.isCompleted);
        break;
      case TodoFilter.today:
        filtered = todos.where((t) => isDueWithin(t, startOfToday, endOfToday));
        break;
      case TodoFilter.thisWeek:
        filtered = todos.where((t) => isDueWithin(t, startOfToday, endOfWeek));
        break;
      case TodoFilter.all:
        filtered = todos;
        break;
      case TodoFilter.completed:
        filtered = todos.where((t) => t.isCompleted);
        break;
      case TodoFilter.byTag:
        filtered = filterTag == null
            ? todos
            : todos.where((t) => t.tags
                .any((tag) => tag.characterTagId == filterTag!.characterTagId));
        break;
      case TodoFilter.byPriority:
        filtered = filterPriority == null
            ? todos
            : todos.where((t) => t.priority == filterPriority);
        break;
    }

    final result = filtered.toList();
    switch (sort) {
      case TodoSort.dueDate:
        result.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TodoSort.priority:
        result.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case TodoSort.difficulty:
        result.sort((a, b) => b.difficulty.index.compareTo(a.difficulty.index));
        break;
      case TodoSort.alphabetical:
        result.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
    }
    return result;
  }

  @override
  List<Object?> get props => [
        todos,
        availableTags,
        character ?? '',
        characterStats,
        filter,
        filterTag,
        filterPriority,
        sort,
        viewMode,
        activeEncounter,
        activeQuestZone,
      ];
}
