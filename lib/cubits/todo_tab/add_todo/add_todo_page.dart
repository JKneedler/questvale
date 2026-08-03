import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todo_tab/add_todo/add_todo_cubit.dart';
import 'package:questvale/cubits/todo_tab/add_todo/add_todo_view.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:sqflite/sqflite.dart';

class AddTodoPage {
  static Future<void> showModal(
    BuildContext context,
    VoidCallback onTodoAdded,
    String characterId, {
    DateTime? initialDueDate,
  }) {
    return showModalBottomSheet<dynamic>(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => AddTodoCubit(
          TodoRepository(db: context.read<Database>()),
          CharacterRepository(db: context.read<Database>()),
          characterId,
          initialDueDate: initialDueDate,
        ),
        child: AddTodoView(
          onTodoAdded: onTodoAdded,
        ),
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
