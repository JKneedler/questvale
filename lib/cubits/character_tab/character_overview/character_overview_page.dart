import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character_tab/character/character_cubit.dart';
import 'package:questvale/cubits/character_tab/character_overview/character_overview_cubit.dart';
import 'package:questvale/cubits/character_tab/character_overview/character_overview_state.dart';
import 'package:questvale/cubits/home/character_data_cubit.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_card_border.dart';
import 'package:questvale/widgets/qv_inset_background.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_metal_corner_border.dart';
import 'package:sqflite/sqflite.dart';

class CharacterOverviewPage extends StatelessWidget {
  const CharacterOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final character = context.read<CharacterDataCubit>().state.character;
    if (character == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return BlocProvider<CharacterOverviewCubit>(
      create: (context) => CharacterOverviewCubit(
          characterId: character.id, db: context.read<Database>()),
      child: CharacterOverviewView(),
    );
  }
}

class CharacterOverviewView extends StatelessWidget {
  const CharacterOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    const bodyPadding = 6.0;

    const gridSpacing = 6.0;
    return BlocBuilder<CharacterOverviewCubit, CharacterOverviewState>(
        builder: (context, characterOverviewState) {
      final character = context.watch<CharacterDataCubit>().state.character;
      final characterStats =
          context.watch<CharacterDataCubit>().state.combatStats;
      if (character == null || characterStats == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        children: [
          QvAppBar(title: 'Character'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: bodyPadding),
              child: Column(
                children: [
                  SizedBox(
                    width:
                        MediaQuery.of(context).size.width - (bodyPadding * 2),
                    height: 180,
                    child: QvMetalCornerBorder(
                      widthFactor: 0.95,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      color: colorScheme.secondary,
                      child: Column(
                        spacing: 6,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text('Level ${character.level}',
                                    style: TextStyle(
                                      fontSize: 20,
                                    )),
                              ),
                              Expanded(
                                  child: Text(
                                character.name,
                                style: TextStyle(fontSize: 24),
                                textAlign: TextAlign.center,
                              )),
                              SizedBox(
                                  width: 100,
                                  child: Text(
                                    'Mage',
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.end,
                                  )),
                            ],
                          ),
                          ResourceBar(
                            maxValue: 200,
                            currentValue: character.currentExp,
                            color: EXP_COLOR,
                            startAlignment: Alignment.centerLeft,
                            width: double.infinity,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ResourceBar(
                                maxValue: characterStats.maxHealth,
                                currentValue: character.currentHealth,
                                color: HEALTH_COLOR,
                                startAlignment: Alignment.centerLeft,
                                width: MediaQuery.of(context).size.width * 0.4,
                              ),
                              ResourceBar(
                                maxValue: characterStats.maxResource,
                                currentValue: character.currentMana,
                                color: MANA_COLOR,
                                startAlignment: Alignment.centerRight,
                                width: MediaQuery.of(context).size.width * 0.4,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            spacing: 6,
                            children: [
                              HeaderInfoSlide(
                                  title: 'Gold',
                                  value: '${character.gold}',
                                  color: GOLD_COLOR),
                              HeaderInfoSlide(
                                  title: 'Action Points',
                                  value: '${character.attacksRemaining}',
                                  color: ACTION_POINTS_COLOR),
                              HeaderInfoSlide(
                                  title: 'Skill Points',
                                  value: '3',
                                  color: SKILL_POINTS_COLOR),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Expanded(
                    child: SizedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: gridSpacing,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: gridSpacing,
                              children: [
                                // Inventory
                                Expanded(
                                  flex: 6,
                                  child: QvInsetBackground(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    type: QvInsetBackgroundType.secondary,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text('Equipment',
                                            style: TextStyle(
                                                fontSize: 16, height: 1)),
                                        Expanded(
                                          child: Column(
                                            spacing: gridSpacing,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  spacing: gridSpacing,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    EquipmentItem(
                                                      equipment:
                                                          characterOverviewState
                                                                  .equipmentSlots[
                                                              EquipmentSlot
                                                                  .weapon
                                                                  .index],
                                                      equipmentSlot:
                                                          EquipmentSlot.weapon,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  spacing: gridSpacing,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    EquipmentItem(
                                                      equipment:
                                                          characterOverviewState
                                                                  .equipmentSlots[
                                                              EquipmentSlot
                                                                  .head.index],
                                                      equipmentSlot:
                                                          EquipmentSlot.head,
                                                    ),
                                                    EquipmentItem(
                                                      equipment:
                                                          characterOverviewState
                                                                  .equipmentSlots[
                                                              EquipmentSlot
                                                                  .hands.index],
                                                      equipmentSlot:
                                                          EquipmentSlot.hands,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  spacing: gridSpacing,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    EquipmentItem(
                                                      equipment:
                                                          characterOverviewState
                                                                  .equipmentSlots[
                                                              EquipmentSlot
                                                                  .body.index],
                                                      equipmentSlot:
                                                          EquipmentSlot.body,
                                                    ),
                                                    EquipmentItem(
                                                      equipment:
                                                          characterOverviewState
                                                                  .equipmentSlots[
                                                              EquipmentSlot
                                                                  .feet.index],
                                                      equipmentSlot:
                                                          EquipmentSlot.feet,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  spacing: gridSpacing,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    EquipmentItem(
                                                      equipment:
                                                          characterOverviewState
                                                                  .equipmentSlots[
                                                              EquipmentSlot
                                                                  .neck.index],
                                                      equipmentSlot:
                                                          EquipmentSlot.neck,
                                                    ),
                                                    EquipmentItem(
                                                      equipment:
                                                          characterOverviewState
                                                                  .equipmentSlots[
                                                              EquipmentSlot
                                                                  .ring.index],
                                                      equipmentSlot:
                                                          EquipmentSlot.ring,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: QvButton(
                                          child: Center(
                                            child: Text(
                                              'Combat\nStats',
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  height: 1,
                                                  color: colorScheme.secondary),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: QvButton(
                                          child: Center(
                                            child: Text(
                                              'Materials',
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  color: colorScheme.secondary),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: gridSpacing,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: QvInsetBackground(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    type: QvInsetBackgroundType.secondary,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text('Skills',
                                            style: TextStyle(
                                                fontSize: 16, height: 1)),
                                        Expanded(
                                          child: Column(
                                            spacing: gridSpacing,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  spacing: gridSpacing,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    SkillItem(),
                                                    SkillItem(),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  spacing: gridSpacing,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    SkillItem(),
                                                    SkillItem(),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: QvInsetBackground(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    type: QvInsetBackgroundType.secondary,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text('Potions',
                                            style: TextStyle(
                                                fontSize: 16, height: 1)),
                                        Expanded(
                                          child: Column(
                                            spacing: gridSpacing,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  spacing: gridSpacing,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    SkillItem(),
                                                    PotionItem(),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  spacing: gridSpacing,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    PotionItem(),
                                                    PotionItem(),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: QvInsetBackground(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    type: QvInsetBackgroundType.secondary,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          'Artifact',
                                        ),
                                        Expanded(
                                          child: Row(
                                            spacing: gridSpacing,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              QvCardBorder(
                                                type: QvCardBorderType.surface,
                                                width: 65,
                                                child: Center(
                                                  child: Text(
                                                    'Empty',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        height: 1),
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  '+10% Exp Gain\n+1 AP per kill',
                                                  style: TextStyle(
                                                      fontSize: 16, height: 1),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
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
                  ),
                  SizedBox(height: gridSpacing),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class ResourceBar extends StatelessWidget {
  const ResourceBar({
    super.key,
    required this.maxValue,
    required this.currentValue,
    required this.color,
    required this.startAlignment,
    required this.width,
  });
  final int maxValue;
  final int currentValue;
  final Color color;
  final Alignment startAlignment;
  final double width;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.primary),
        color: colorScheme.surface,
      ),
      width: width,
      height: 20,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          FractionallySizedBox(
            widthFactor: currentValue / maxValue,
            child: Container(
              color: color,
              height: 20,
            ),
          ),
          SizedBox(
            height: 20,
            child: Center(
              child: Text(
                '$currentValue / $maxValue',
                style: TextStyle(fontSize: 16, color: Colors.white, height: 1),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderInfoSlide extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const HeaderInfoSlide(
      {super.key,
      required this.title,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: QvInsetBackground(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        type: QvInsetBackgroundType.surface,
        child: SizedBox(
          height: 40,
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 16, height: 1)),
              Text(value,
                  style: TextStyle(fontSize: 24, height: 1, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class EquipmentItem extends StatelessWidget {
  final Equipment? equipment;
  final EquipmentSlot equipmentSlot;
  const EquipmentItem({super.key, this.equipment, required this.equipmentSlot});

  String _iconPath(CharacterClass characterClass) {
    if (equipment == null) {
      return '';
    }
    return equipment!.iconPath(characterClass);
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final character = context.read<CharacterDataCubit>().state.character;
    if (character == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<CharacterCubit>().onEquipmentSlotSelected(equipmentSlot);
        },
        child: QvCardBorder(
          type: equipment == null
              ? QvCardBorderType.surface
              : QvCardBorderType.rarity,
          bgColor: colorScheme.surface,
          rarity: equipment == null ? Rarity.common : equipment!.rarity,
          padding: EdgeInsets.all(20),
          child: equipment == null
              ? Center(
                  child: Text(
                    'Empty',
                    style: TextStyle(fontSize: 20, height: 1),
                    textAlign: TextAlign.center,
                  ),
                )
              : Center(
                  child: Image.asset(
                    _iconPath(character.characterClass),
                    filterQuality: FilterQuality.none,
                    scale: .1,
                    fit: BoxFit.fitHeight,
                  ),
                ),
        ),
      ),
    );
  }
}

class SkillItem extends StatelessWidget {
  const SkillItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: QvButton(
        padding: EdgeInsets.all(16),
        buttonColor: ButtonColor.getColor(Rarity.legendary),
        child: Center(
          child: Image.asset(
            'images/pixel-icons/leaf.png',
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}

class PotionItem extends StatelessWidget {
  const PotionItem({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: QvCardBorder(
        type: QvCardBorderType.rarity,
        rarity: Rarity.rare,
        bgColor: colorScheme.surface,
        padding: EdgeInsets.all(16),
        child: Center(
          child: Image.asset(
            'images/pixel-icons/potion-star.png',
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
