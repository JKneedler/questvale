import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/todo_tab/todos_calendar/todos_calendar_cubit.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_cubit.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_view.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/services/enemy_attack_scheduling_service.dart';
import 'package:sqflite/sqflite.dart';

class TodosOverviewPage extends StatelessWidget {
  const TodosOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TodosOverviewCubit(
            TodoRepository(db: context.read<Database>()),
            CharacterRepository(db: context.read<Database>()),
            QuestRepository(db: context.read<Database>()),
            EncounterRepository(db: context.read<Database>()),
            context.read<GameData>(),
            context.read<PlayerCubit>(),
            EnemyAttackSchedulingService(db: context.read<Database>()),
          ),
        ),
        BlocProvider(create: (context) => TodosCalendarCubit()),
      ],
      child: const TodosOverviewView(),
    );
  }
}
