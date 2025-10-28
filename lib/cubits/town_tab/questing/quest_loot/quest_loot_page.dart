import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/town_tab/questing/quest_loot/quest_loot_cubit.dart';
import 'package:questvale/cubits/town_tab/questing/quest_loot/quest_loot_state.dart';
import 'package:questvale/cubits/town_tab/questing/simple_equipment_slice.dart';
import 'package:questvale/cubits/town_tab/questing/loot_summary_slice.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_metal_corner_border.dart';
import 'package:questvale/cubits/town_tab/questing/quest_encounter/quest_encounter_cubit.dart';
import 'package:sqflite/sqflite.dart';

class QuestLootPage extends StatelessWidget {
  const QuestLootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuestLootCubit>(
      create: (context) => QuestLootCubit(
        quest: context.read<QuestEncounterCubit>().state.quest,
        db: context.read<Database>(),
      ),
      child: const QuestLootView(),
    );
  }
}

class QuestLootView extends StatelessWidget {
  const QuestLootView({super.key});

  String _getQuestTimeLengthString(BuildContext context) {
    final quest = context.read<QuestEncounterCubit>().state.quest;
    final questTimeLength =
        quest.completedAt?.difference(quest.createdAt) ?? Duration.zero;
    final hours = questTimeLength.inHours;
    final minutes = questTimeLength.inMinutes % 60;
    final seconds = questTimeLength.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<QuestLootCubit, QuestLootState>(
        builder: (context, questLootState) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              width: MediaQuery.of(context).size.width * 0.8,
              child: QvMetalCornerBorder(
                heightFactor: 0.97,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  spacing: 8,
                  children: [
                    Text(
                      'Quest Summary',
                      style: TextStyle(
                        fontSize: 24,
                        color: colorScheme.primary,
                        height: 1,
                      ),
                    ),
                    Container(
                      height: 1,
                      width: 230,
                      color: colorScheme.primary,
                    ),
                    SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 10,
                          children: [
                            Expanded(
                                child: SummarySlice(
                              title: 'Time',
                              value: _getQuestTimeLengthString(context),
                              valueColor: Colors.white,
                            )),
                            Expanded(
                                child: SummarySlice(
                              title: 'XP',
                              value: '${questLootState.xp}',
                              valueColor: Colors.greenAccent,
                            )),
                            Expanded(
                              child: SummarySlice(
                                title: 'Gold',
                                value: '${questLootState.gold}',
                                valueColor: Colors.yellowAccent,
                              ),
                            ),
                          ],
                        )),
                    Text(
                      'Drops',
                      style: TextStyle(
                        fontSize: 22,
                        color: colorScheme.primary,
                        height: 1,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'images/ui/secondary-background-2x.png'),
                            centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: questLootState.equipment.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: SimpleEquipmentSlice(
                                    equipment: questLootState.equipment[index]),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    QvButton(
                      onTap: () {
                        context.read<QuestEncounterCubit>().finishQuest();
                      },
                      height: 50,
                      child: Center(
                        child: Text(
                          'Continue...',
                          style: TextStyle(
                            fontSize: 22,
                            color: colorScheme.secondary,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
