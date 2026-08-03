import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todo_tab/edit_todo/edit_todo_cubit.dart';
import 'package:questvale/cubits/todo_tab/edit_todo/edit_todo_view.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:sqflite/sqflite.dart';

class EditTodoPage {
  static Future<void> show(BuildContext context, Todo todo) {
    return showModalBottomSheet<dynamic>(
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
      // The Home page's bottom nav bar lives outside the tab's own nested
      // Navigator, so the default (nearest) Navigator's overlay stops above
      // it. Route through the root Navigator instead so the sheet's overlay
      // spans the full screen and its bottom covers the nav bar.
      useRootNavigator: true,
    );
  }
}
