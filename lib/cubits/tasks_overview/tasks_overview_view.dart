import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/edit_task/edit_task_view.dart';
import 'package:questvale/cubits/home/home_page.dart';
import 'package:questvale/cubits/tasks_overview/tasks_overview_cubit.dart';
import 'package:questvale/cubits/tasks_overview/tasks_overview_item.dart';
import 'package:questvale/cubits/tasks_overview/tasks_overview_state.dart';
import 'package:questvale/main_drawer.dart';

class TasksOverviewView extends StatelessWidget {
  const TasksOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final taskCubit = context.read<TasksOverviewCubit>();

    return Scaffold(
      appBar: AppBar(
          title:
              Text('Questvale', style: TextStyle(color: colorScheme.onPrimary)),
          backgroundColor: colorScheme.primary,
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
          actions: [
            IconButton(
              icon: Icon(
                Symbols.add,
                color: colorScheme.onPrimary,
                size: 28,
              ),
              onPressed: () async {
                await Navigator.push(
                    context, EditTaskView.route(pageTitle: "Create Task"));
                taskCubit.loadTasks();
              },
            ),
          ]),
      body: Expanded(child: BlocBuilder<TasksOverviewCubit, TasksOverviewState>(
          builder: (context, tasksOverviewState) {
        return ListView.builder(
            shrinkWrap: true,
            itemCount: tasksOverviewState.tasks.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              return TasksOverviewItem(task: tasksOverviewState.tasks[index]);
            });
      })),
      backgroundColor: colorScheme.surface,
    );
  }
}
