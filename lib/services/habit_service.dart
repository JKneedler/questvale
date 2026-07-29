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
  // an empty period breaks it to 0, with no grace period. Pure computation
  // (like completeOnce) — returns the same Todo, unchanged, if no period
  // has actually elapsed yet, so the caller can skip writing it back.
  Todo advancePeriodsIfNeeded(Todo todo, {DateTime? now}) {
    if (!todo.isHabit ||
        todo.timeframe == null ||
        todo.currentPeriodStart == null) {
      return todo;
    }

    final currentTime = now ?? DateTime.now();
    var periodStart = todo.currentPeriodStart!;
    var periodEnd = _periodEnd(periodStart, todo.timeframe!);
    var streak = todo.currentStreak;
    var completions = todo.completionsInCurrentPeriod;
    var elapsed = false;

    while (!currentTime.isBefore(periodEnd)) {
      streak = completions > 0 ? streak + 1 : 0;
      completions = 0;
      periodStart = periodEnd;
      periodEnd = _periodEnd(periodStart, todo.timeframe!);
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

  DateTime _periodEnd(DateTime periodStart, HabitTimeframe timeframe) {
    switch (timeframe) {
      case HabitTimeframe.daily:
        return periodStart.add(const Duration(days: 1));
      case HabitTimeframe.weekly:
        return periodStart.add(const Duration(days: 7));
      case HabitTimeframe.monthly:
        return DateTime(
          periodStart.year,
          periodStart.month + 1,
          periodStart.day,
          periodStart.hour,
          periodStart.minute,
          periodStart.second,
        );
    }
  }
}
