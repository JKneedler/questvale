import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/tasks_overview/tasks_overview_state.dart';
import 'package:questvale/data/repositories/task_repository.dart';
import 'package:questvale/data/models/task.dart';

class TasksOverviewCubit extends Cubit<TasksOverviewState> {
  final TaskRepository taskRepository;

  TasksOverviewCubit(this.taskRepository)
      : super(TasksOverviewState(tasks: [])) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    final taskList = await taskRepository.getTasks();
    printTasks(taskList);

    final newState = state.copyWith(tasks: taskList);

    emit(newState);
  }

  Future<void> deleteTask(Task taskToDelete) async {
    await taskRepository.deleteTask(taskToDelete);

    loadTasks();
  }

  Future<void> toggleCompletion(Task taskToUpdate) async {
    final updatedTask =
        taskToUpdate.copyWith(isCompleted: !taskToUpdate.isCompleted);
    await taskRepository.updateTask(updatedTask);

    loadTasks();
  }

  void printTasks(List<Task> taskList) {
    print('-------------- TASKS --------------');
    for (Task task in taskList) {
      print(task.toString());
    }
  }
}
