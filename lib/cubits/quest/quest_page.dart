import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/character_data_cubit.dart';
import 'package:questvale/cubits/quest/quest_cubit.dart';
import 'package:questvale/cubits/quest/quest_state.dart';
import 'package:questvale/cubits/quest_encounter/quest_encounter_page.dart';
import 'package:questvale/cubits/town/town_page.dart';

class QuestPage extends StatelessWidget {
  const QuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuestCubit(
          showQuestView:
              context.read<CharacterDataCubit>().state.quest != null),
      child: BlocBuilder<QuestCubit, QuestState>(
        builder: (context, state) {
          if (state.showQuestView) {
            return const QuestEncounterPage();
          } else {
            return TownPage(
              onQuestCreated: () => {
                context.read<CharacterDataCubit>().updateQuest(),
                context.read<QuestCubit>().showQuestView(),
              },
            );
          }
        },
      ),
    );
  }
}
