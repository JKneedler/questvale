import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todos_overview/todos_overview_cubit.dart';
import 'package:questvale/cubits/todos_overview/todos_overview_view.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:sqflite/sqflite.dart';

class TodosOverviewPage extends StatelessWidget {
  const TodosOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodosOverviewCubit(
        TodoRepository(db: context.read<Database>()),
        CharacterRepository(db: context.read<Database>()),
      ),
      child: const TodosOverviewView(),
    );
  }
}
