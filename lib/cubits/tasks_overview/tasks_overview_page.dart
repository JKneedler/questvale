import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/tasks_overview/tasks_overview_cubit.dart';
import 'package:questvale/cubits/tasks_overview/tasks_overview_view.dart';
import 'package:questvale/data/repositories/task_repository.dart';
import 'package:sqflite/sqflite.dart';

class TasksOverviewPage extends StatelessWidget {
  const TasksOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<Database>();

    return BlocProvider(
        create: (context) => TasksOverviewCubit(TaskRepository(db: db)),
        child: TasksOverviewView());
  }
}
