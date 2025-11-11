import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/town_tab/forging/forge/forge_page.dart';
import 'package:questvale/cubits/town_tab/questing/quest_encounter/quest_encounter_page.dart';
import 'package:questvale/cubits/town_tab/select_quest/select_quest_page.dart';
import 'package:questvale/cubits/town_tab/town/town_cubit.dart';
import 'package:questvale/cubits/town_tab/town/town_state.dart';
import 'package:questvale/widgets/qv_animated_transition.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_metal_corner_border.dart';
import 'package:questvale/widgets/qv_white_card.dart';
import 'package:sqflite/sqflite.dart';

class TownPage extends StatelessWidget {
  const TownPage({super.key});

  Widget _getTownPage(BuildContext context, TownState townState) {
    switch (townState.currentLocation) {
      case TownLocation.townSquare:
        return TownSquare(key: const ValueKey('townSquare'));
      case TownLocation.questBoard:
        return SelectQuestPage(key: const ValueKey('selectQuestPage'));
      case TownLocation.quest:
        if (townState.quest != null) {
          return QuestEncounterPage(
              key: const ValueKey('questEncounterPage'),
              quest: townState.quest!);
        } else {
          return Center(child: Text('No quest found'));
        }
      case TownLocation.shop:
        return SizedBox();
      case TownLocation.guildHall:
        return SizedBox();
      case TownLocation.forge:
        return ForgePage(key: const ValueKey('forgePage'));
      case TownLocation.lab:
        return SizedBox();
      case TownLocation.gemforge:
        return SizedBox();
      case TownLocation.reliquary:
        return SizedBox();
      default:
        return Center(child: Text('Not implemented'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TownCubit>(
        create: (context) => TownCubit(
              character: context.read<PlayerCubit>().state.character!,
              db: context.read<Database>(),
            ),
        child: BlocBuilder<TownCubit, TownState>(builder: (context, townState) {
          return QvAnimatedTransition(
            duration: const Duration(milliseconds: 200),
            type: townState.currentLocation == TownLocation.townSquare
                ? QvAnimatedTransitionType.slideRight
                : QvAnimatedTransitionType.slideLeft,
            child: _getTownPage(context, townState),
          );
        }));
  }
}

class TownSquare extends StatelessWidget {
  const TownSquare({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    const padding = 16.0;

    return Scaffold(
      body: Column(
        children: [
          QvAppBar(title: 'Town Square'),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: padding, bottom: padding),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 4,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.125,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: padding, right: padding),
                          child: GestureDetector(
                            onTap: () => {
                              context.read<TownCubit>().state.quest != null
                                  ? context
                                      .read<TownCubit>()
                                      .setCurrentLocation(TownLocation.quest)
                                  : context
                                      .read<TownCubit>()
                                      .setCurrentLocation(
                                        TownLocation.questBoard,
                                      ),
                            },
                            child: QvMetalCornerBorder(
                              padding: EdgeInsets.only(
                                  left: 52, right: 52, top: 30, bottom: 30),
                              color: colorScheme.secondary,
                              child: Row(
                                spacing: 16,
                                children: [
                                  Image.asset(
                                    'images/pixel-icons/portal.png',
                                    filterQuality: FilterQuality.none,
                                  ),
                                  Text(
                                    context.read<TownCubit>().state.quest !=
                                            null
                                        ? 'Continue Quest'
                                        : 'Quest Board',
                                    style: TextStyle(
                                      color: colorScheme.onSecondary,
                                      fontSize: 28,
                                    ),
                                  ),
                                  Text(
                                    '>',
                                    style: TextStyle(
                                      color: colorScheme.onSecondary,
                                      fontSize: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                          height: 4,
                          width: MediaQuery.of(context).size.width * 0.85,
                          color: colorScheme.secondary),
                      SizedBox(height: 4),
                      SizedBox(
                        height: 140,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: padding, right: padding),
                          child: Row(
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TownLocationCard(
                                location: TownLocation.shop,
                                title: 'Shop',
                                image: 'images/pixel-icons/all-coins-stack.png',
                                requiredLevel: 0,
                              ),
                              TownLocationCard(
                                location: TownLocation.guildHall,
                                title: 'Guild Hall',
                                image: 'images/pixel-icons/letter.png',
                                requiredLevel: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 140,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: padding, right: padding),
                          child: Row(
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TownLocationCard(
                                location: TownLocation.forge,
                                title: 'Forge',
                                image:
                                    'images/pixel-icons/anvil-hammer-star.png',
                                requiredLevel: 10,
                              ),
                              TownLocationCard(
                                location: TownLocation.lab,
                                title: 'Lab',
                                image: 'images/pixel-icons/potion-star.png',
                                requiredLevel: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 140,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: padding, right: padding),
                          child: Row(
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TownLocationCard(
                                location: TownLocation.gemforge,
                                title: 'Gemforge',
                                image: 'images/pixel-icons/jewel-star.png',
                                requiredLevel: 40,
                              ),
                              TownLocationCard(
                                location: TownLocation.reliquary,
                                title: 'Reliquary',
                                image: 'images/pixel-icons/artifact.png',
                                requiredLevel: 80,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TownLocationCard extends StatelessWidget {
  const TownLocationCard({
    super.key,
    required this.title,
    required this.image,
    this.requiredLevel = 0,
    required this.location,
  });

  final String title;
  final String image;
  final int requiredLevel;
  final TownLocation location;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    final character = context.read<PlayerCubit>().state.character;
    final isUnlocked = character != null && character.level >= requiredLevel;

    return Expanded(
      child: ColorFiltered(
        colorFilter: isUnlocked
            ? const ColorFilter.mode(Colors.transparent, BlendMode.color)
            : const ColorFilter.matrix(<double>[
                // R         G         B         A  Bias
                0.2126, 0.7152, 0.0722, 0, 0, // R'
                0.2126, 0.7152, 0.0722, 0, 0, // G'
                0.2126, 0.7152, 0.0722, 0, 0, // B'
                0, 0, 0, 1, 0, // A'
              ]),
        child: QVWhiteCard(
          onTap: () => context.read<TownCubit>().setCurrentLocation(location),
          padding: EdgeInsets.only(top: 20, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                image,
                width: 48,
                height: 48,
                scale: .1,
                filterQuality: FilterQuality.none,
              ),
              SizedBox(height: 8),
              QvButton(
                onTap: () =>
                    context.read<TownCubit>().setCurrentLocation(location),
                buttonColor: ButtonColor.primary,
                child: Text(
                  isUnlocked ? title : 'Level $requiredLevel',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
