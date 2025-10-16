import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/character_data_cubit.dart';
import 'package:questvale/cubits/home/character_data_state.dart';
import 'package:questvale/cubits/quest_encounter/quest_encounter_cubit.dart';
import 'package:questvale/cubits/quest_encounter/quest_encounter_state.dart';
import 'package:sqflite/sqflite.dart';

class QuestEncounterPage extends StatelessWidget {
  const QuestEncounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterDataCubit, CharacterDataState>(
        builder: (context, characterDataState) {
      return BlocProvider<QuestEncounterCubit>(
        create: (context) => QuestEncounterCubit(
          quest: characterDataState.quest!,
          db: context.read<Database>(),
        ),
        child: QuestEncounterView(),
      );
    });
  }
}

class QuestEncounterView extends StatelessWidget {
  const QuestEncounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestEncounterCubit, QuestEncounterState>(
      builder: (context, state) {
        return BlocListener<QuestEncounterCubit, QuestEncounterState>(
          listenWhen: (prev, next) =>
              prev.status == QuestEncounterStatus.generating &&
              next.status != QuestEncounterStatus.generating,
          listener: (context, questEncounterState) {
            context.read<CharacterDataCubit>().updateQuest();
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'images/backgrounds/${state.quest.zone.name.toLowerCase()}-encounter.png'),
                colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.2), BlendMode.darken),
                fit: BoxFit.fill,
                filterQuality: FilterQuality.low,
              ),
            ),
            child: Column(
              children: [
                Text(
                    'Encounter ${state.quest.curEncounterNum} / ${state.quest.numEncountersCurFloor}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
