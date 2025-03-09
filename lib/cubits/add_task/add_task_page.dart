import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/add_task/add_task_cubit.dart';
import 'package:questvale/cubits/add_task/add_task_view.dart';
import 'package:questvale/data/repositories/tag_repository.dart';
import 'package:questvale/data/repositories/task_repository.dart';
import 'package:sqflite/sqflite.dart';

class AddTaskPage {
  static Future<void> showModal(
      BuildContext context, Function() onTaskAdded) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) => BlocProvider(
        create: (context) => AddTaskCubit(
          TaskRepository(db: context.read<Database>()),
          TagRepository(db: context.read<Database>()),
        ),
        child: AddTaskView(onTaskAdded: onTaskAdded),
      ),
    );
  }
}
