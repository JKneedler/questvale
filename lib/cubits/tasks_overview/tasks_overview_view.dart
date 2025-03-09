import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/tasks_overview/tasks_overview_cubit.dart';
import 'package:questvale/cubits/tasks_overview/tasks_overview_item.dart';
import 'package:questvale/cubits/tasks_overview/tasks_overview_state.dart';
import 'package:questvale/cubits/add_task/add_task_page.dart';

class TasksOverviewView extends StatelessWidget {
  const TasksOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskCubit = context.read<TasksOverviewCubit>();
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Questvale', style: TextStyle(color: colorScheme.onSurface)),
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        shape: CircleBorder(),
        onPressed: () async {
          await AddTaskPage.showModal(
            context,
            () => taskCubit.loadTasks(),
          );
        },
        child: Icon(
          Icons.add,
          size: 32,
          color: colorScheme.onPrimary,
        ),
      ),
      body: Expanded(child: BlocBuilder<TasksOverviewCubit, TasksOverviewState>(
          builder: (context, tasksOverviewState) {
        return ListView.builder(
            shrinkWrap: true,
            itemCount: tasksOverviewState.tasks.length,
            padding: const EdgeInsets.all(2),
            itemBuilder: (context, index) {
              return TasksOverviewItem(task: tasksOverviewState.tasks[index]);
            });
      })),
      backgroundColor: colorScheme.surface,
    );
  }
}
