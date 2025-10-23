import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/character_data_cubit.dart';
import 'package:questvale/cubits/quest/background_page.dart';
import 'package:questvale/cubits/quest/quest_cubit.dart';
import 'package:questvale/cubits/quest/quest_state.dart';
import 'package:questvale/cubits/quest_encounter/quest_encounter_page.dart';
import 'package:questvale/cubits/quest_loot/quest_loot_page.dart';
import 'package:questvale/cubits/town/town_page.dart';
import 'package:sqflite/sqflite.dart';

class QuestPage extends StatelessWidget {
  const QuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuestCubit(
          character: context.read<CharacterDataCubit>().state.character!,
          db: context.read<Database>(),
          showQuestView:
              context.read<CharacterDataCubit>().state.quest != null),
      child: BlocListener<QuestCubit, QuestState>(
        listenWhen: (prev, next) => prev.quest != null && next.quest == null,
        listener: (context, questState) {
          if (questState.quest == null) {
            context.read<CharacterDataCubit>().updateQuest();
          }
        },
        child: BlocBuilder<QuestCubit, QuestState>(
          builder: (context, state) {
            if (state.showQuestView && state.quest != null) {
              if (state.quest!.completedAt != null) {
                return QuestLootPage();
              } else {
                return QuestEncounterPage(quest: state.quest!);
              }
            } else if (context.read<CharacterDataCubit>().state.quest != null) {
              return BackgroundPage(
                zoneName:
                    context.read<CharacterDataCubit>().state.quest!.zone.name,
                darkened: false,
                child: SizedBox(),
              );
            } else {
              return TownPage(
                onQuestCreated: () => {
                  context.read<CharacterDataCubit>().updateQuest(),
                  context.read<QuestCubit>().onCreateQuest(),
                },
              );
            }
          },
        ),
      ),
    );
  }
}
