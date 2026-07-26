import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/repositories/todo_repository.dart';

class HabitService {
  final TodoRepository todoRepository;

  HabitService({required this.todoRepository});

  // Multi-check habits just increment; single-check habits toggle like a Task.
  Future<void> completeOnce(Todo todo) async {
    if (!todo.isHabit) return;

    final Todo updated;
    if (todo.allowsMultipleCompletions) {
      updated = todo.copyWith(
        completionsInCurrentPeriod: todo.completionsInCurrentPeriod + 1,
        isCompleted: true,
      );
    } else {
      final isCompleting = !todo.isCompleted;
      updated = todo.copyWith(
        isCompleted: isCompleting,
        completionsInCurrentPeriod: isCompleting ? 1 : 0,
      );
    }
    await todoRepository.updateTodo(updated);
  }
}
