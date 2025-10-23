import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/quest/quest_cubit.dart';
import 'package:questvale/cubits/quest_loot/quest_loot_cubit.dart';
import 'package:questvale/cubits/quest_loot/quest_loot_state.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_fade_in.dart';
import 'package:questvale/widgets/qv_metal_corner_border.dart';
import 'package:sqflite/sqflite.dart';

class QuestLootPage extends StatelessWidget {
  const QuestLootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuestLootCubit>(
      create: (context) => QuestLootCubit(
        quest: context.read<QuestCubit>().state.quest!,
        db: context.read<Database>(),
      ),
      child: const QuestLootView(),
    );
  }
}

class QuestLootView extends StatelessWidget {
  const QuestLootView({super.key});

  String _getQuestTimeLengthString(BuildContext context) {
    final quest = context.read<QuestCubit>().state.quest!;
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
      if (questLootState.questSummary == null) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            QvFadeIn(
              duration: questLootState.firstPlay
                  ? const Duration(milliseconds: 400)
                  : const Duration(milliseconds: 100),
              delay: questLootState.firstPlay
                  ? const Duration(milliseconds: 200)
                  : Duration.zero,
              beginOpacity: 0.0,
              endOpacity: 1.0,
              child: SizedBox(
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
                                value: '${questLootState.questSummary!.xp}',
                                valueColor: Colors.greenAccent,
                              )),
                              Expanded(
                                child: SummarySlice(
                                  title: 'Gold',
                                  value: '${questLootState.questSummary!.gold}',
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
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
                              padding: const EdgeInsets.all(0),
                              itemCount: 20,
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  height: 50,
                                  child: Text(
                                    'Item $index',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      QvButton(
                        onTap: () {
                          context.read<QuestCubit>().finishQuest();
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
            ),
          ],
        ),
      );
    });
  }
}

class SummarySlice extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  const SummarySlice(
      {super.key,
      required this.title,
      required this.value,
      required this.valueColor});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/ui/secondary-background-2x.png'),
          centerSlice: Rect.fromLTWH(16, 16, 32, 32),
          fit: BoxFit.fill,
          filterQuality: FilterQuality.none,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.primary,
              height: 1,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              color: valueColor,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
