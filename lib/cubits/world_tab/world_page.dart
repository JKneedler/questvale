import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/nav_cubit.dart';
import 'package:questvale/cubits/home/nav_state.dart';
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
  static const _worldTabIndex = 0;

  const WorldView({super.key});

  @override
  Widget build(BuildContext context) {
    final worldCubit = context.read<WorldCubit>();
    return BlocListener<NavCubit, NavState>(
      // WorldCubit only loads its quest once, at construction — and
      // WorldPage is built once for the app's lifetime (IndexedStack keeps
      // every tab mounted). Actions taken elsewhere (e.g. Settings'
      // cancel/delete quest admin action) can delete the quest out from
      // under it, so reload whenever the player comes back to this tab.
      listenWhen: (previous, current) =>
          current.tab == _worldTabIndex && previous.tab != _worldTabIndex,
      listener: (context, state) => worldCubit.loadQuest(),
      child:
          BlocBuilder<WorldCubit, WorldState>(builder: (context, worldState) {
        if (worldState.quest == null) {
          return TownPage();
        }
        return QuestEncounterPage(
          key: const ValueKey('questEncounterPage'),
          quest: worldState.quest!,
        );
      }),
    );
  }
}
