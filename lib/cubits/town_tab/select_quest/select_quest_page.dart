import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/town_tab/select_quest/select_quest_cubit.dart';
import 'package:questvale/cubits/town_tab/select_quest/select_quest_state.dart';
import 'package:questvale/cubits/town_tab/town/town_cubit.dart';
import 'package:questvale/cubits/town_tab/town/town_state.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/providers/game_data_models/enemy_data.dart';
import 'package:questvale/data/providers/game_data_models/quest_zone.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:questvale/widgets/qv_enemy_info_modal.dart';
import 'package:questvale/widgets/qv_gray_filter.dart';
import 'package:questvale/widgets/qv_card_border.dart';
import 'package:sqflite/sqflite.dart';

class SelectQuestPage extends StatelessWidget {
  const SelectQuestPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    final questZones = context.read<GameData>().questZones;
    final character = context.read<PlayerCubit>().state.character;

    if (character == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          QvAppBar(
            title: 'Quest Board',
            onBackButtonPressed: () => context
                .read<TownCubit>()
                .setCurrentLocation(TownLocation.townSquare),
          ),
          Expanded(
            child: Container(
              color: colorScheme.surface,
              child: BlocProvider(
                create: (context) => SelectQuestCubit(
                    db: context.read<Database>(),
                    questZones: questZones,
                    character: character),
                child: BlocBuilder<SelectQuestCubit, SelectQuestState>(
                    builder: (context, selectQuestState) {
                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 10,
                      bottom: 10,
                    ),
                    itemCount: questZones.length,
                    itemBuilder: (context, index) {
                      final isOpen =
                          selectQuestState.selectedQuestZoneIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SelectQuestZoneCard(
                          questZone: questZones[index],
                          isOpen: isOpen,
                          onTap: () => context
                              .read<SelectQuestCubit>()
                              .toggleQuestZone(index),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SelectQuestZoneCard extends StatelessWidget {
  const SelectQuestZoneCard({
    super.key,
    required this.questZone,
    required this.isOpen,
    required this.onTap,
  });

  final QuestZone questZone;
  final bool isOpen;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: isOpen ? 300 : 120,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onTap,
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: .94,
                    child: Container(
                        margin: const EdgeInsets.only(top: 6),
                        height: 105,
                        padding: const EdgeInsets.only(
                          left: 40,
                          right: 40,
                          top: 20,
                          bottom: 20,
                        ),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'images/backgrounds/${questZone.id}.png'),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 30,
                                    child: Text(questZone.name,
                                        style: TextStyle(
                                          fontSize: 28,
                                          color: colorScheme.secondary,
                                        )),
                                  ),
                                  Text('Level ${questZone.requiredLevel}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: colorScheme.secondary,
                                      )),
                                ],
                              ),
                            ),
                            Center(
                              child: Text(
                                '>',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: colorScheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                height: isOpen ? 180 : 0,
                child: FractionallySizedBox(
                  widthFactor: .94,
                  child: Container(
                    color: colorScheme.secondary,
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        children: [
                          isOpen
                              ? SizedBox(
                                  height: 80,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Center(
                                            child: Text(
                                          '<',
                                          style: TextStyle(
                                              fontSize: 24,
                                              color: colorScheme.onSecondary),
                                        )),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: questZone.enemies.length,
                                          itemBuilder: (context, index) {
                                            return ZoneEnemyCard(
                                              enemy: questZone.enemies[index],
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 30,
                                        child: Center(
                                            child: Text(
                                          '>',
                                          style: TextStyle(
                                              fontSize: 24,
                                              color: colorScheme.onSecondary),
                                        )),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(height: 80),
                          SizedBox(height: 16),
                          BlocListener<SelectQuestCubit, SelectQuestState>(
                            listenWhen: (prev, next) =>
                                next.questCreateState ==
                                QuestCreateStates.createdSuccess,
                            listener: (context, state) {
                              if (state.questCreateState ==
                                  QuestCreateStates.createdSuccess) {
                                context.read<TownCubit>().onQuestCreated();
                              } else if (state.questCreateState ==
                                  QuestCreateStates.createdFailed) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Failed to create quest')));
                              }
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: GestureDetector(
                                onTap: () => {
                                  context.read<SelectQuestCubit>().beginQuest(),
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      centerSlice:
                                          Rect.fromLTWH(16, 16, 32, 32),
                                      image: AssetImage(
                                        'images/ui/buttons/primary-button-2x.png',
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      context
                                                  .read<SelectQuestCubit>()
                                                  .state
                                                  .questCreateState ==
                                              QuestCreateStates.creating
                                          ? 'Embarking...'
                                          : 'Embark',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: colorScheme.secondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.only(
                  left: 40,
                  right: 40,
                  top: 30,
                  bottom: 30,
                ),
                foregroundDecoration: BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage('images/ui/borders/primary-border-2x.png'),
                    centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),
                child: Column(
                  children: [],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ZoneEnemyCard extends StatelessWidget {
  const ZoneEnemyCard({
    super.key,
    required this.enemy,
  });

  final EnemyData enemy;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    // TODO: Add discovered logic
    bool discovered = true;
    return GestureDetector(
      onTap: () =>
          discovered ? QvEnemyInfoModal.showModal(context, enemy) : null,
      child: QVGrayFilter(
        isEnabled: !discovered,
        child: Container(
          margin: const EdgeInsets.only(right: 4),
          child: QvCardBorder(
            rarity: enemy.rarity,
            bgColor: colorScheme.surface,
            width: 70,
            height: 80,
            child: Image.asset(
                discovered
                    ? 'images/enemies/${enemy.name.toLowerCase().replaceAll(' ', '-')}.png'
                    : 'images/pixel-icons/question-mark.png',
                filterQuality: FilterQuality.none),
          ),
        ),
      ),
    );
  }
}
