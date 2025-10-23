import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/chest_loot/chest_loot_page.dart';
import 'package:questvale/cubits/combat_encounter/combat_encounter_page.dart';
import 'package:questvale/cubits/combat_loot/combat_loot_page.dart';
import 'package:questvale/cubits/quest/background_page.dart';
import 'package:questvale/cubits/quest/quest_cubit.dart';
import 'package:questvale/cubits/quest/quest_state.dart';
import 'package:questvale/cubits/quest_encounter/chest_encounter_page.dart';
import 'package:questvale/cubits/quest_encounter/quest_encounter_cubit.dart';
import 'package:questvale/cubits/quest_encounter/quest_encounter_state.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:sqflite/sqflite.dart';

class QuestEncounterPage extends StatelessWidget {
  const QuestEncounterPage({super.key, required this.quest});
  final Quest quest;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuestEncounterCubit>(
      create: (context) => QuestEncounterCubit(
        quest: quest,
        db: context.read<Database>(),
      ),
      child: QuestEncounterView(),
    );
  }
}

class QuestEncounterView extends StatelessWidget {
  const QuestEncounterView({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<QuestEncounterCubit, QuestEncounterState>(
      builder: (context, state) {
        return BlocListener<QuestCubit, QuestState>(
          listenWhen: (prev, next) =>
              prev.quest?.curEncounterNum != next.quest?.curEncounterNum,
          listener: (context, questCubitState) {
            if (questCubitState.quest != null) {
              context
                  .read<QuestEncounterCubit>()
                  .reloadEncounter(questCubitState.quest!);
            }
          },
          child: BackgroundPage(
            zoneName: context.watch<QuestCubit>().state.quest!.zone.name,
            darkened: state.darkened,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: QvButton(
                    darkened: state.darkened,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Encounter ${context.watch<QuestCubit>().state.quest!.curEncounterNum} / ${context.watch<QuestCubit>().state.quest!.numEncountersCurFloor}',
                          style: TextStyle(
                              color: colorScheme.secondary, fontSize: 26),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                state.encounter?.encounterType.isCombatEncounter() ?? false
                    ? state.encounter!.completedAt != null
                        ? CombatLootPage()
                        : Expanded(
                            child: CombatEncounterPage(),
                          )
                    : const SizedBox(),
                state.encounter?.encounterType.isChestEncounter() ?? false
                    ? state.encounter!.completedAt != null
                        ? ChestLootPage()
                        : ChestEncounterPage(
                            rarity:
                                state.encounter!.chestRarity ?? Rarity.common,
                            firstPlay: state.encounter!.createdAt
                                    .millisecondsSinceEpoch >
                                DateTime.now().millisecondsSinceEpoch -
                                    ENCOUNTER_FIRST_PLAY_DELAY,
                          )
                    : const SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }
}
