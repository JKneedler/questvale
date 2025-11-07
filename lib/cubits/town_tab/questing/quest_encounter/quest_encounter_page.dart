import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/character_data_cubit.dart';
import 'package:questvale/cubits/town_tab/questing/chest_loot/chest_loot_page.dart';
import 'package:questvale/cubits/town_tab/questing/combat_encounter/combat_encounter_page.dart';
import 'package:questvale/cubits/town_tab/questing/combat_loot/combat_loot_page.dart';
import 'package:questvale/cubits/town_tab/questing/quest_encounter/background_page.dart';
import 'package:questvale/cubits/town_tab/questing/quest_encounter/chest_encounter_page.dart';
import 'package:questvale/cubits/town_tab/questing/quest_encounter/quest_encounter_cubit.dart';
import 'package:questvale/cubits/town_tab/questing/quest_encounter/quest_encounter_state.dart';
import 'package:questvale/cubits/town_tab/questing/quest_loot/quest_loot_page.dart';
import 'package:questvale/cubits/town_tab/town/town_cubit.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_animated_transition.dart';
import 'package:questvale/widgets/qv_quest_encounter_header.dart';
import 'package:sqflite/sqflite.dart';

class QuestEncounterPage extends StatelessWidget {
  const QuestEncounterPage({super.key, required this.quest});
  final Quest quest;

  @override
  Widget build(BuildContext context) {
    final questZones = context.read<GameData>().questZones;
    final questZone = questZones.firstWhere((zone) => zone.id == quest.zoneId);
    return BlocProvider<QuestEncounterCubit>(
      create: (context) => QuestEncounterCubit(
        quest: quest,
        initialQuestStatus: QuestStatus.questBegin,
        db: context.read<Database>(),
        questZone: questZone,
      ),
      child: QuestEncounterView(),
    );
  }
}

class QuestEncounterView extends StatelessWidget {
  const QuestEncounterView({super.key});

  Widget _getQuestView(BuildContext context, QuestEncounterState questState) {
    final encounter = questState.encounter;
    if (questState.questStatus == QuestStatus.questBegin) {
      return SizedBox(child: Text('Quest Begin'));
    } else if (questState.questStatus == QuestStatus.floorBegin) {
      return SizedBox(child: Text('Floor Begin'));
    } else if (questState.questStatus == QuestStatus.encounterInProgress) {
      if (encounter != null) {
        if (encounter.encounterType.isCombatEncounter()) {
          return CombatEncounterPage(
              key: const ValueKey('combatEncounterPage'));
        } else if (encounter.encounterType.isChestEncounter()) {
          return ChestEncounterPage(
            rarity: encounter.chestRarity ?? Rarity.common,
            firstPlay: false,
            key: const ValueKey('chestEncounterPage'),
          );
        } else {
          return SizedBox();
        }
      } else {
        return SizedBox();
      }
    } else if (questState.questStatus == QuestStatus.encounterCompleted) {
      if (encounter != null) {
        if (encounter.encounterType.isCombatEncounter()) {
          return CombatLootPage(key: const ValueKey('combatLootPage'));
        } else if (encounter.encounterType.isChestEncounter()) {
          return ChestLootPage(key: const ValueKey('chestLootPage'));
        } else {
          return SizedBox();
        }
      } else {
        return SizedBox();
      }
    } else if (questState.questStatus == QuestStatus.questCompleted) {
      return QuestLootPage(key: const ValueKey('questLootPage'));
    }
    return SizedBox();
  }

  // TODO
  QvAnimatedTransitionType getTransitionType(QuestEncounterState questState) {
    if (questState.questStatus == QuestStatus.encounterCompleted) {
      return QvAnimatedTransitionType.fade;
    }
    return QvAnimatedTransitionType.slideLeft;
  }

  // TODO
  Duration getTransitionDuration(QuestEncounterState questState) {
    final encounter = questState.encounter;
    if (encounter == null) {
      return const Duration(milliseconds: 0);
    }
    if (encounter.completedAt != null) {
      return const Duration(milliseconds: 400);
    }
    return const Duration(milliseconds: 600);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestEncounterCubit, QuestEncounterState>(
      builder: (context, questState) {
        return MultiBlocListener(
          listeners: [
            BlocListener<QuestEncounterCubit, QuestEncounterState>(
              listenWhen: (prev, next) =>
                  next.questStatus == QuestStatus.encounterDeleted,
              listener: (context, questState) {
                context.read<TownCubit>().loadQuest();
              },
            ),
            BlocListener<QuestEncounterCubit, QuestEncounterState>(
              listenWhen: (prev, next) =>
                  next.questStatus == QuestStatus.questDeleted,
              listener: (context, questState) {
                context.read<TownCubit>().loadQuest();
              },
            ),
            BlocListener<QuestEncounterCubit, QuestEncounterState>(
              listenWhen: (prev, next) => next.questStatus != prev.questStatus,
              listener: (context, questState) {
                context.read<CharacterDataCubit>().loadCharacter();
              },
            ),
          ],
          child: BackgroundPage(
            zoneName: context.read<QuestEncounterCubit>().questZone.name,
            darkened: questState.darkened,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  questState.questStatus == QuestStatus.encounterInProgress ||
                          questState.questStatus ==
                              QuestStatus.encounterCompleted
                      ? QvQuestEncounterHeader(
                          darkened: questState.darkened,
                          curEncounterNum: questState.quest.curEncounterNum,
                          numEncountersCurFloor:
                              questState.quest.numEncountersCurFloor,
                        )
                      : SizedBox.shrink(),
                  Expanded(
                    child: QvAnimatedTransition(
                      duration: getTransitionDuration(questState),
                      type: getTransitionType(questState),
                      child: _getQuestView(context, questState),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
