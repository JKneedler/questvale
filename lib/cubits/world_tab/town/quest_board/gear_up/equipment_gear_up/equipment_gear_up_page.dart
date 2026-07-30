import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/theme/theme_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/equipment_gear_up/equipment_gear_up_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/equipment_gear_up/equipment_gear_up_state.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_card_border.dart';
import 'package:questvale/widgets/qv_equipment_item.dart';
import 'package:sqflite/sqflite.dart';

class EquipmentGearUpPage extends StatelessWidget {
  const EquipmentGearUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final character = context.read<PlayerCubit>().state.character;
    if (character == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return BlocProvider<EquipmentGearUpCubit>(
      create: (context) => EquipmentGearUpCubit(
          db: context.read<Database>(), character: character),
      child: EquipmentGearUpView(),
    );
  }
}

class EquipmentGearUpView extends StatelessWidget {
  const EquipmentGearUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EquipmentGearUpCubit, EquipmentGearUpState>(
      builder: (context, equipmentGearUpState) {
        if (equipmentGearUpState.currentState ==
            EquipmentGearUpStates.selectingEquipment) {
          return EquipmentSelectionView();
        }
        return EquipmentGearUpOverview();
      },
    );
  }
}

class EquipmentGearUpOverview extends StatelessWidget {
  const EquipmentGearUpOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EquipmentGearUpCubit, EquipmentGearUpState>(
      builder: (context, equipmentGearUpState) {
        return Expanded(
          child: Column(
            spacing: 8,
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    Expanded(
                      child: WeaponCard(),
                    ),
                    Expanded(
                      child:
                          PlaceholderSlotCard(label: 'Artifact', fontSize: 20),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const columnSpacing = 4.0;
                    const cardSpacing = 4.0;
                    const maxCardsInColumn = 3;
                    const columnCount = 3;
                    final maxCardHeight = (constraints.maxHeight -
                            (maxCardsInColumn - 1) * cardSpacing) /
                        maxCardsInColumn;
                    final maxCardWidth = (constraints.maxWidth -
                            (columnCount - 1) * columnSpacing) /
                        columnCount;
                    final cardSize = maxCardHeight < maxCardWidth
                        ? maxCardHeight
                        : maxCardWidth;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: cardSpacing,
                            children: [
                              GearSlotCard(
                                  width: cardSize,
                                  height: cardSize,
                                  equipment: equipmentGearUpState.equippedRing1,
                                  onTap: () => context
                                      .read<EquipmentGearUpCubit>()
                                      .onEquipmentSlotSelected(
                                          EquipmentSlot.ring,
                                          ringSlot: 1)),
                              GearSlotCard(
                                  width: cardSize,
                                  height: cardSize,
                                  equipment: equipmentGearUpState.equippedRing2,
                                  onTap: () => context
                                      .read<EquipmentGearUpCubit>()
                                      .onEquipmentSlotSelected(
                                          EquipmentSlot.ring,
                                          ringSlot: 2)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: cardSpacing,
                            children: [
                              GearSlotCard(
                                  width: cardSize,
                                  height: cardSize,
                                  equipment:
                                      equipmentGearUpState.equippedHelmet,
                                  onTap: () => context
                                      .read<EquipmentGearUpCubit>()
                                      .onEquipmentSlotSelected(
                                          EquipmentSlot.head)),
                              GearSlotCard(
                                  width: cardSize,
                                  height: cardSize,
                                  equipment:
                                      equipmentGearUpState.equippedChestplate,
                                  onTap: () => context
                                      .read<EquipmentGearUpCubit>()
                                      .onEquipmentSlotSelected(
                                          EquipmentSlot.body)),
                              GearSlotCard(
                                  width: cardSize,
                                  height: cardSize,
                                  equipment: equipmentGearUpState.equippedBoots,
                                  onTap: () => context
                                      .read<EquipmentGearUpCubit>()
                                      .onEquipmentSlotSelected(
                                          EquipmentSlot.feet)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: cardSpacing,
                            children: [
                              GearSlotCard(
                                  width: cardSize,
                                  height: cardSize,
                                  equipment:
                                      equipmentGearUpState.equippedAmulet,
                                  onTap: () => context
                                      .read<EquipmentGearUpCubit>()
                                      .onEquipmentSlotSelected(
                                          EquipmentSlot.neck)),
                              GearSlotCard(
                                  width: cardSize,
                                  height: cardSize,
                                  equipment:
                                      equipmentGearUpState.equippedGloves,
                                  onTap: () => context
                                      .read<EquipmentGearUpCubit>()
                                      .onEquipmentSlotSelected(
                                          EquipmentSlot.hands)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    Expanded(
                        child: Column(
                      spacing: 8,
                      children: [
                        Expanded(child: PlaceholderSlotCard(label: 'Potion 1')),
                        Expanded(child: PlaceholderSlotCard(label: 'Potion 2')),
                      ],
                    )),
                    Expanded(
                        child: Column(
                      spacing: 8,
                      children: [
                        Expanded(child: PlaceholderSlotCard(label: 'Potion 3')),
                        Expanded(child: PlaceholderSlotCard(label: 'Potion 4')),
                      ],
                    )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _equipmentSlotLabel(EquipmentSlot slot, int? ringSlot) {
  switch (slot) {
    case EquipmentSlot.weapon:
      return 'Weapon';
    case EquipmentSlot.head:
      return 'Helmet';
    case EquipmentSlot.body:
      return 'Chestplate';
    case EquipmentSlot.hands:
      return 'Gloves';
    case EquipmentSlot.feet:
      return 'Boots';
    case EquipmentSlot.neck:
      return 'Amulet';
    case EquipmentSlot.ring:
      return ringSlot == 2 ? 'Ring 2' : 'Ring 1';
  }
}

class EquipmentSelectionView extends StatelessWidget {
  const EquipmentSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EquipmentGearUpCubit, EquipmentGearUpState>(
      builder: (context, equipmentGearUpState) {
        final cubit = context.read<EquipmentGearUpCubit>();
        final slot = equipmentGearUpState.selectedEquipmentSlot;
        if (slot == null) {
          return const SizedBox();
        }
        final colorScheme = Theme.of(context).colorScheme;
        final primaryDark = context.watch<ThemeCubit>().state.theme.primaryDark;
        return Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => cubit.onCancelSelection(),
                      child: SizedBox(
                        width: 32,
                        height: 28,
                        child: Text(
                          '<',
                          style: TextStyle(
                              fontSize: 24, color: colorScheme.onSurface),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          _equipmentSlotLabel(
                              slot, equipmentGearUpState.selectedRingSlot),
                          style: TextStyle(
                              fontSize: 22, color: colorScheme.onSurface),
                        ),
                      ),
                    ),
                    SizedBox(width: 32),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text('Currently Equipped',
                        style: TextStyle(fontSize: 18, height: 1)),
                    SizedBox(height: 6),
                    QvEquipmentItem(
                      equipment: cubit.selectedSlotEquippedItem,
                      isEquipped: true,
                      showName: true,
                    ),
                    SizedBox(height: 6),
                  ],
                ),
              ),
              Container(
                height: 2,
                width: double.infinity,
                color: colorScheme.onSurface,
              ),
              Container(
                height: 4,
                width: double.infinity,
                color: colorScheme.primary,
              ),
              Container(
                height: 2,
                width: double.infinity,
                color: primaryDark,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  color: colorScheme.secondary,
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    itemCount: equipmentGearUpState.inventoryEquipment.length,
                    itemBuilder: (context, index) {
                      final equipment =
                          equipmentGearUpState.inventoryEquipment[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: QvEquipmentItem(
                          equipment: equipment,
                          isEquipped: false,
                          showName: true,
                          onTap: () {
                            cubit.equipEquipment(equipment);
                            context.read<PlayerCubit>().loadCharacter();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WeaponCard extends StatelessWidget {
  const WeaponCard({super.key});

  @override
  Widget build(BuildContext context) {
    final equippedWeapon =
        context.watch<EquipmentGearUpCubit>().state.equippedWeapon;
    return GearSlotCard(
      equipment: equippedWeapon,
      padding: EdgeInsets.all(12),
      emptyFontSize: 20,
      onTap: () => context
          .read<EquipmentGearUpCubit>()
          .onEquipmentSlotSelected(EquipmentSlot.weapon),
    );
  }
}

class PlaceholderSlotCard extends StatelessWidget {
  final String label;
  final double fontSize;
  const PlaceholderSlotCard(
      {super.key, required this.label, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return QvCardBorder(
      type: QvCardBorderType.surface,
      bgColor: colorScheme.surface,
      padding: EdgeInsets.all(12),
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontSize: fontSize, height: 1),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class GearSlotCard extends StatelessWidget {
  final Equipment? equipment;
  final double width;
  final double height;
  final EdgeInsets padding;
  final double emptyFontSize;
  final VoidCallback? onTap;

  const GearSlotCard({
    super.key,
    required this.equipment,
    this.width = 0,
    this.height = 0,
    this.padding = const EdgeInsets.all(16),
    this.emptyFontSize = 14,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final character = context.watch<PlayerCubit>().state.character;
    if (character == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final card = QvCardBorder(
      width: width,
      height: height,
      type: equipment == null
          ? QvCardBorderType.surface
          : QvCardBorderType.rarity,
      rarity: equipment == null ? Rarity.common : equipment!.rarity,
      bgColor: colorScheme.surface,
      padding: padding,
      child: equipment == null
          ? Center(
              child: Text(
                'Empty',
                style: TextStyle(fontSize: emptyFontSize, height: 1),
                textAlign: TextAlign.center,
              ),
            )
          : Center(
              child: Image.asset(
                equipment!.iconPath(character.characterClass),
                filterQuality: FilterQuality.none,
                scale: .1,
                fit: BoxFit.fitHeight,
              ),
            ),
    );
    if (onTap == null) {
      return card;
    }
    return GestureDetector(onTap: onTap, child: card);
  }
}
