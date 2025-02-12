import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/edit_task/edit_task_cubit.dart';
import 'package:questvale/cubits/edit_task/edit_task_view.dart';
import 'package:questvale/data/models/task.dart';
import 'package:questvale/data/repositories/tag_repository.dart';
import 'package:questvale/data/repositories/task_repository.dart';
import 'package:sqflite/sqflite.dart';

class EditTaskPage extends StatelessWidget {
  final Task? startTask;
  final String pageTitle;

  const EditTaskPage({super.key, required this.pageTitle, this.startTask});

  static Route<void> route({required String pageTitle, Task? startTask}) {
    return MaterialPageRoute(
        builder: (context) => BlocProvider(
              create: (context) => EditTaskCubit(
                  TaskRepository(db: context.read<Database>()),
                  TagRepository(db: context.read<Database>()),
                  startTask),
              child: EditTaskView(pageTitle: pageTitle),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<Database>();

    return BlocProvider(
      create: (context) => EditTaskCubit(
          TaskRepository(db: db), TagRepository(db: db), startTask),
      child: EditTaskView(pageTitle: pageTitle),
    );
  }
}
