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
}
