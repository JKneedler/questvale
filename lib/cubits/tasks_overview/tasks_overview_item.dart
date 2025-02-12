import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:questvale/cubits/edit_task/edit_task_page.dart';
import 'package:questvale/cubits/tasks_overview/tasks_overview_cubit.dart';
import '../../data/models/task.dart';

class TasksOverviewItem extends StatelessWidget {
  final Task task;
  const TasksOverviewItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final taskCubit = context.read<TasksOverviewCubit>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 80,
      child: Slidable(
        endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.3,
            children: [
              SlidableAction(
                onPressed: (context) => taskCubit.deleteTask(task),
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                icon: Icons.delete,
                label: 'Delete',
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
            ]),
        child: Container(
            padding:
                const EdgeInsets.only(bottom: 10, top: 10, right: 10, left: 10),
            decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow,
                    offset: const Offset(0.1, 0.1),
                  )
                ],
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    activeColor: colorScheme.onSurface,
                    value: task.isCompleted,
                    onChanged: (value) => taskCubit.toggleCompletion(task),
                    shape: const CircleBorder(eccentricity: 0.5),
                  ),
                ),
                const VerticalDivider(
                  thickness: 2,
                ),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditTaskPage(
                                pageTitle: 'Edit Task', startTask: task)));
                    taskCubit.loadTasks();
                  },
                  child: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        task.name,
                        style: (task.isCompleted
                            ? TextStyle(
                                fontSize: 18,
                                color: Color.lerp(colorScheme.onSurface,
                                    colorScheme.surface, 0.5),
                                decoration: TextDecoration.lineThrough,
                              )
                            : TextStyle(
                                fontSize: 18,
                                color: colorScheme.onSurface,
                              )),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
