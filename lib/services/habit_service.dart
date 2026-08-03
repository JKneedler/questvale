import 'package:questvale/data/models/todo.dart';

class HabitCompletionResult {
  // Whether this call represents a genuine new completion (as opposed to
  // un-completing) — the caller uses this to decide whether to award AP.
  final bool isNewCompletion;
  final Todo updated;

  const HabitCompletionResult({
    required this.isNewCompletion,
    required this.updated,
  });
}

class HabitService {
  // Habit "days" roll over at this hour (device-local time), not midnight —
  // so a completion right after midnight still counts toward the previous
  // day/period until the actual rollover.
  static const rolloverHour = 2;

  // The start of the current rollover-aligned period containing `dateTime`
  // — used to anchor a new habit's currentPeriodStart so every subsequent
  // period boundary (daily/weekly/monthly) lands on rolloverHour too.
  static DateTime startOfPeriodContaining(DateTime dateTime) {
    final rolloverToday =
        DateTime(dateTime.year, dateTime.month, dateTime.day, rolloverHour);
    return dateTime.isBefore(rolloverToday)
        ? rolloverToday.subtract(const Duration(days: 1))
        : rolloverToday;
  }

  // Anchors a brand-new (or just-reconfigured) habit's currentPeriodStart
  // as of `referenceDate`. For most configurations this is simply "the
  // rollover period containing referenceDate" — but a weekly habit with
  // specific weekdays selected must anchor on an actual selected weekday,
  // not just whatever day it happens to be created/edited on, otherwise
  // day-gating (see TodosOverviewState.isDueWithin) would show/hide it on
  // the wrong day immediately. Walks backward to the most recent matching
  // weekday.
  static DateTime anchorPeriodStart({
    required HabitTimeframe timeframe,
    required Set<int> repeatWeekdays,
    required DateTime referenceDate,
  }) {
    final today = startOfPeriodContaining(referenceDate);
    if (timeframe != HabitTimeframe.weekly || repeatWeekdays.isEmpty) {
      return today;
    }
    var candidate = today;
    for (var i = 0; i < 7; i++) {
      if (repeatWeekdays.contains(candidate.weekday)) return candidate;
      candidate = candidate.subtract(const Duration(days: 1));
    }
    return today; // unreachable — repeatWeekdays is non-empty here
  }

  // Multi-check habits just increment; single-check habits toggle like a
  // Task. Pure computation — doesn't persist, so the caller can merge in
  // other field changes (e.g. AP-award bookkeeping) into a single write.
  HabitCompletionResult completeOnce(Todo todo) {
    if (!todo.isHabit) {
      return HabitCompletionResult(isNewCompletion: false, updated: todo);
    }

    if (todo.allowsMultipleCompletions) {
      final updated = todo.copyWith(
        completionsInCurrentPeriod: todo.completionsInCurrentPeriod + 1,
        isCompleted: true,
      );
      return HabitCompletionResult(isNewCompletion: true, updated: updated);
    }

    final isCompleting = !todo.isCompleted;
    final updated = todo.copyWith(
      isCompleted: isCompleting,
      completionsInCurrentPeriod: isCompleting ? 1 : 0,
    );
    return HabitCompletionResult(
        isNewCompletion: isCompleting, updated: updated);
  }

  // Rolls a habit's period forward to "now", incrementing/breaking the
  // streak for each elapsed period along the way. Streak changes happen
  // here — at the period boundary — not per-completion, per the design:
  // a completed period (at least one completion) increments the streak by
  // exactly one regardless of how many multi-check completions happened;
  // an empty period breaks it to 0, with no grace period. Each hop this
  // walks (via _nextOccurrence) is one streak-unit regardless of what it
  // represents — a daily tick, a single selected weekday, or a monthly
  // date. Pure computation (like completeOnce) — returns the same Todo,
  // unchanged, if no period has actually elapsed yet, so the caller can
  // skip writing it back.
  Todo advancePeriodsIfNeeded(Todo todo, {DateTime? now}) {
    if (!todo.isHabit ||
        todo.timeframe == null ||
        todo.currentPeriodStart == null) {
      return todo;
    }

    final currentTime = now ?? DateTime.now();
    var periodStart = todo.currentPeriodStart!;
    var periodEnd = _nextOccurrence(periodStart, todo);
    var streak = todo.currentStreak;
    var completions = todo.completionsInCurrentPeriod;
    var elapsed = false;

    while (!currentTime.isBefore(periodEnd)) {
      streak = completions > 0 ? streak + 1 : 0;
      completions = 0;
      periodStart = periodEnd;
      periodEnd = _nextOccurrence(periodStart, todo);
      elapsed = true;
    }

    if (!elapsed) return todo;
    return todo.copyWith(
      currentStreak: streak,
      completionsInCurrentPeriod: completions,
      currentPeriodStart: periodStart,
      isCompleted: false,
      completionAwarded: false,
    );
  }

  DateTime _nextOccurrence(DateTime periodStart, Todo todo) {
    final interval = todo.repeatInterval < 1 ? 1 : todo.repeatInterval;
    switch (todo.timeframe!) {
      case HabitTimeframe.daily:
        return periodStart.add(Duration(days: interval));
      case HabitTimeframe.weekly:
        return _nextWeeklyOccurrence(periodStart, todo.repeatWeekdays, interval);
      case HabitTimeframe.monthly:
        return todo.monthlyRepeatMode == MonthlyRepeatMode.dayOfWeek
            ? _nextMonthlyDayOfWeekOccurrence(periodStart, interval)
            : _nextMonthlyDayOfMonthOccurrence(periodStart, interval);
    }
  }

  // If no specific weekdays are selected, falls back to the original plain
  // rolling weekly period (exact legacy behavior — also covers habits
  // persisted before this feature existed). Otherwise, interval only
  // applies BETWEEN full cycles: hopping to a later selected weekday
  // within the same week never skips, only wrapping to the next cycle's
  // first selected weekday does.
  DateTime _nextWeeklyOccurrence(
      DateTime periodStart, Set<int> weekdays, int interval) {
    if (weekdays.isEmpty) {
      return periodStart.add(Duration(days: 7 * interval));
    }
    final sorted = weekdays.toList()..sort();
    final currentWeekMonday =
        periodStart.subtract(Duration(days: periodStart.weekday - 1));
    final nextInWeek =
        sorted.firstWhere((wd) => wd > periodStart.weekday, orElse: () => -1);
    if (nextInWeek != -1) {
      return currentWeekMonday.add(Duration(days: nextInWeek - 1));
    }
    final targetWeekMonday =
        currentWeekMonday.add(Duration(days: 7 * interval));
    return targetWeekMonday.add(Duration(days: sorted.first - 1));
  }

  DateTime _nextMonthlyDayOfMonthOccurrence(
      DateTime periodStart, int interval) {
    final targetMonthIndex = periodStart.month - 1 + interval;
    final targetYear = periodStart.year + targetMonthIndex ~/ 12;
    final targetMonth = targetMonthIndex % 12 + 1;
    final daysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    final targetDay = periodStart.day > daysInTargetMonth
        ? daysInTargetMonth
        : periodStart.day;
    return DateTime(targetYear, targetMonth, targetDay, periodStart.hour,
        periodStart.minute, periodStart.second);
  }

  // Weekday + ordinal-within-month (1st/2nd/3rd/.../5th occurrence) are
  // derived from periodStart itself every time, not stored separately —
  // periodStart always represents "the current active occurrence," so its
  // own weekday/ordinal IS the recurrence pattern. Falls back to the last
  // occurrence of that weekday in the target month if the Nth doesn't
  // exist (e.g. a stored "5th" often doesn't exist — and if the "5th"
  // doesn't exist, the 4th naturally IS the last one).
  DateTime _nextMonthlyDayOfWeekOccurrence(
      DateTime periodStart, int interval) {
    final weekday = periodStart.weekday;
    final ordinal = ((periodStart.day - 1) ~/ 7) + 1;

    final targetMonthIndex = periodStart.month - 1 + interval;
    final targetYear = periodStart.year + targetMonthIndex ~/ 12;
    final targetMonth = targetMonthIndex % 12 + 1;

    final firstOfTargetMonth = DateTime(targetYear, targetMonth, 1);
    final firstOccurrenceOffset =
        (weekday - firstOfTargetMonth.weekday + 7) % 7;
    var targetDay = 1 + firstOccurrenceOffset + 7 * (ordinal - 1);

    final daysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    if (targetDay > daysInTargetMonth) {
      targetDay -= 7;
    }
    return DateTime(targetYear, targetMonth, targetDay, periodStart.hour,
        periodStart.minute, periodStart.second);
  }
}
