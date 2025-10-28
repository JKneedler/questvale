import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todo_tab/edit_todo/edit_todo_cubit.dart';
import 'package:questvale/cubits/todo_tab/edit_todo/edit_todo_view.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:sqflite/sqflite.dart';

class EditTodoPage {
  static void show(BuildContext context, Todo todo) {
    showModalBottomSheet<dynamic>(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => EditTodoCubit(
          todoRepository: TodoRepository(db: context.read<Database>()),
          characterRepository:
              CharacterRepository(db: context.read<Database>()),
          todo: todo,
        ),
        child: EditTodoView(todo: todo),
      ),
      isScrollControlled: true,
      isDismissible: true,
      barrierColor: Colors.transparent,
    );
  }
}
