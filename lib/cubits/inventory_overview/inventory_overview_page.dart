import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/inventory_overview/inventory_overview_cubit.dart';
import 'package:questvale/cubits/inventory_overview/inventory_overview_state.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/inventory.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:sqflite/sqflite.dart';

class InventoryOverviewPage extends StatelessWidget {
  const InventoryOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InventoryOverviewCubit(
          CharacterRepository(
            db: context.read<Database>().database,
          ),
          EquipmentRepository(
            db: context.read<Database>().database,
          )),
      child: InventoryOverviewScaffold(),
    );
  }
}

class InventoryOverviewScaffold extends StatelessWidget {
  const InventoryOverviewScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inventory',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: Icon(
              Symbols.add,
              color: colorScheme.onPrimary,
              size: 28,
            ),
            onPressed: () =>
                context.read<InventoryOverviewCubit>().createEquipmentItem(),
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
      body: BlocBuilder<InventoryOverviewCubit, InventoryOverviewState>(
          builder: (context, inventoryState) {
        final character = inventoryState.character;
        if (character == null) {
          return Icon(Icons.sync);
        } else {
          return InventoryOverviewView(inventory: character.inventory);
        }
      }),
    );
  }
}

class InventoryOverviewView extends StatelessWidget {
  final Inventory inventory;

  const InventoryOverviewView({super.key, required this.inventory});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: 10,
        ),
        child: Column(
          children: [
            EquippedView(inventory: inventory),
            EquipmentView(inventory: inventory),
          ],
        ),
      ),
    );
  }
}

class EquippedView extends StatelessWidget {
  final Inventory inventory;

  const EquippedView({super.key, required this.inventory});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Row(
          spacing: 10,
          children: [
            EquippedSlotContainer(
              slotName: 'Ring',
              slotItem: inventory.ring,
            ),
            EquippedSlotContainer(
              slotName: 'Helmet',
              slotItem: inventory.helmet,
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            EquippedSlotContainer(
              slotName: 'Amulet',
              slotItem: inventory.amulet,
            ),
            EquippedSlotContainer(
              slotName: 'Body',
              slotItem: inventory.body,
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            EquippedSlotContainer(
              slotName: 'Main Hand',
              slotItem: inventory.mainHand,
            ),
            EquippedSlotContainer(
              slotName: 'Gloves',
              slotItem: inventory.gloves,
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            EquippedSlotContainer(
              slotName: 'Off Hand',
              slotItem: inventory.offHand,
            ),
            EquippedSlotContainer(
              slotName: 'Boots',
              slotItem: inventory.boots,
            ),
          ],
        ),
      ],
    );
  }
}

class EquippedSlotContainer extends StatelessWidget {
  final String slotName;
  final Equipment? slotItem;

  const EquippedSlotContainer({
    super.key,
    required this.slotName,
    required this.slotItem,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        height: 100,
        child: Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              slotName,
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Center(
                  child: (slotItem != null
                      ? Text(
                          slotItem!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Text('Empty')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EquipmentView extends StatelessWidget {
  final Inventory inventory;

  const EquipmentView({super.key, required this.inventory});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, left: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Inventory',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                Icon(
                  Symbols.filter_alt,
                  color: colorScheme.onSurface,
                )
              ],
            ),
          ),
          Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: inventory.equipments.length,
            itemBuilder: (context, index) {
              final equipment = inventory.equipments[index];
              const armorGear = [
                EquipmentType.helmet,
                EquipmentType.body,
                EquipmentType.gloves,
                EquipmentType.boots,
              ];
              const damageGear = [
                EquipmentType.oneHandedWeapon,
                EquipmentType.twoHandedWeapon,
                EquipmentType.dagger,
                EquipmentType.bow,
                EquipmentType.wand,
                EquipmentType.staff,
              ];
              const blockChanceGear = [EquipmentType.shield];
              const nothingGear = [
                EquipmentType.ring,
                EquipmentType.amulet,
                EquipmentType.focus,
              ];

              int? value = 0;
              IconData? valueIcon;
              if (armorGear.contains(equipment.type)) {
                value = equipment.armor;
                valueIcon = Symbols.shield;
              } else if (damageGear.contains(equipment.type)) {
                value = equipment.damage;
                valueIcon = Symbols.swords;
              } else if (blockChanceGear.contains(equipment.type)) {
                value = equipment.blockChance;
                valueIcon = Symbols.gpp_bad;
              } else if (nothingGear.contains(equipment.type)) {
                value = null;
                valueIcon = null;
              }
              return EquipmentListItem(
                equipment: equipment,
                value: value,
                valueIcon: valueIcon,
              );
            },
          ),
        ],
      ),
    );
  }
}

class EquipmentListItem extends StatelessWidget {
  final Equipment equipment;
  final int? value;
  final IconData? valueIcon;

  const EquipmentListItem({
    super.key,
    required this.equipment,
    required this.value,
    required this.valueIcon,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    Color itemColor = colorScheme.surfaceContainerHighest;
    switch (equipment.rarity) {
      case EquipmentRarity.uncommon:
        itemColor = Colors.blue[100]!;
        break;
      case EquipmentRarity.rare:
        itemColor = Colors.yellow[300]!;
        break;
      case EquipmentRarity.legendary:
        itemColor = Colors.deepOrange[200]!;
        break;
      default:
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: itemColor,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        height: 100,
        child: Row(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Image(
                image: AssetImage(equipment.image),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 6,
                    children: [
                      Expanded(
                        child: Text(
                          equipment.name,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      (value != null
                          ? Text(
                              '$value',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            )
                          : const SizedBox.shrink()),
                      (valueIcon != null
                          ? Icon(
                              valueIcon,
                              color: colorScheme.onSurface,
                              fill: 1,
                              size: 14,
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                  Divider(
                    height: 5,
                    color: Color.lerp(colorScheme.onSurfaceVariant,
                        colorScheme.surfaceContainerHighest, 0.7),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: equipment.modifiers.length,
                          itemBuilder: (context, index) {
                            final modifier = equipment.modifiers[index];
                            return Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                modifier.name,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, right: 10),
                        child: GestureDetector(
                          onTap: () => {
                            if (!equipment.isEquipped)
                              context
                                  .read<InventoryOverviewCubit>()
                                  .equipEquipment(equipment)
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              border: (equipment.isEquipped
                                  ? null
                                  : Border.all(
                                      color: colorScheme.onSurfaceVariant)),
                            ),
                            padding: EdgeInsets.all(6),
                            child: (equipment.isEquipped
                                ? Text('Equipped')
                                : Text('Equip')),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
