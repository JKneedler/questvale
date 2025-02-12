import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/task.dart';

enum TasksOverviewStatus { initial, loading, success, failure }

class TasksOverviewState extends Equatable {
  final TasksOverviewStatus status;
  final List<Task> tasks;

  const TasksOverviewState({
    this.status = TasksOverviewStatus.initial,
    required this.tasks,
  });

  TasksOverviewState copyWith({
    TasksOverviewStatus? status,
    List<Task>? tasks,
  }) {
    return TasksOverviewState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tasks,
      ];
}
