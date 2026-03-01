import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/questing/quest_encounter/quest_encounter_page.dart';
import 'package:questvale/cubits/world_tab/town/town_page.dart';
import 'package:questvale/cubits/world_tab/world_cubit.dart';
import 'package:questvale/cubits/world_tab/world_state.dart';
import 'package:sqflite/sqflite.dart';

class WorldPage extends StatelessWidget {
  const WorldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WorldCubit>(
        create: (context) => WorldCubit(
            character: context.read<PlayerCubit>().state.character!,
            db: context.read<Database>()),
        child: const WorldView());
  }
}

class WorldView extends StatelessWidget {
  const WorldView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorldCubit, WorldState>(builder: (context, worldState) {
      if (worldState.quest == null) {
        return TownPage();
      }
      return QuestEncounterPage(
        key: const ValueKey('questEncounterPage'),
        quest: worldState.quest!,
      );
    });
  }
}
