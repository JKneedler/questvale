import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/add_todo/add_todo_cubit.dart';
import 'package:questvale/cubits/add_todo/add_todo_view.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:sqflite/sqflite.dart';

class AddTodoPage extends StatelessWidget {
  const AddTodoPage({super.key});

  static Future<void> showModal(
    BuildContext context,
    VoidCallback onTodoAdded,
    String characterId,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocProvider(
        create: (context) => AddTodoCubit(
          TodoRepository(db: context.read<Database>()),
          CharacterRepository(db: context.read<Database>()),
          characterId,
        ),
        child: AddTodoView(
          onTodoAdded: onTodoAdded,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AddTodoView(onTodoAdded: () {});
  }
}
