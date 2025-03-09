import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:questvale/cubits/tasks_overview/tasks_overview_cubit.dart';
import 'package:questvale/widgets/check_box.dart';
import '../../data/models/task.dart';

class TasksOverviewItem extends StatefulWidget {
  final Task task;
  const TasksOverviewItem({super.key, required this.task});

  @override
  State<TasksOverviewItem> createState() => _TasksOverviewItemState();
}

class _TasksOverviewItemState extends State<TasksOverviewItem> {
  bool isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final taskCubit = context.read<TasksOverviewCubit>();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              onPressed: (context) => taskCubit.deleteTask(widget.task),
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ],
        ),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
                color: isHighlighted
                    ? colorScheme.secondary
                    : colorScheme.surfaceContainer,
                borderRadius: const BorderRadius.all(Radius.circular(6))),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                setState(() {
                  isHighlighted = true;
                });
                await Future.delayed(const Duration(milliseconds: 150));
                if (mounted) {
                  setState(() {
                    isHighlighted = false;
                  });
                }
                // await Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => EditTaskPage(
                //         pageTitle: 'Edit Task', startTask: widget.task),
                //   ),
                // );
                // taskCubit.loadTasks();
              },
              child: Material(
                color: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTapDown: (_) => taskCubit.toggleCompletion(widget.task),
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          child: CheckBox(
                            width: 20,
                            height: 20,
                            isChecked: widget.task.isCompleted,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.task.name,
                              softWrap: true,
                              style: (widget.task.isCompleted
                                  ? TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimaryFixedVariant,
                                    )
                                  : TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimaryContainer,
                                    )),
                            ),
                            if (widget.task.description.isNotEmpty)
                              Text(
                                widget.task.description,
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onPrimaryFixedVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
