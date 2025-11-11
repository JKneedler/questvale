import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character_tab/equipment/equipment_cubit.dart';
import 'package:questvale/cubits/character_tab/equipment/equipment_state.dart';
import 'package:questvale/cubits/character_tab/character/character_cubit.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:questvale/widgets/qv_equipment_item.dart';
import 'package:sqflite/sqflite.dart';

class EquipmentPage extends StatelessWidget {
  const EquipmentPage({super.key, required this.equipmentSlot});
  final EquipmentSlot equipmentSlot;

  @override
  Widget build(BuildContext context) {
    final character = context.read<PlayerCubit>().state.character;
    if (character == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return BlocProvider<EquipmentCubit>(
      create: (context) => EquipmentCubit(
          character: character,
          equipmentSlot: equipmentSlot,
          db: context.read<Database>()),
      child: EquipmentView(),
    );
  }
}

class EquipmentView extends StatelessWidget {
  const EquipmentView({super.key});

  String _getEquipmentSlotName(EquipmentSlot equipmentSlot) {
    return equipmentSlot.name[0].toUpperCase() +
        equipmentSlot.name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<EquipmentCubit, EquipmentState>(
        builder: (context, equipmentState) {
      final equipmentSlot = context.read<EquipmentCubit>().equipmentSlot;
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            QvAppBar(
              title: _getEquipmentSlotName(equipmentSlot),
              includeBackButton: true,
              onBackButtonPressed: () {
                context.read<PlayerCubit>().loadCharacter();
                context.read<CharacterCubit>().onBackButtonPressed();
              },
              showAP: false,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text('Currently Equipped',
                      style: TextStyle(fontSize: 18, height: 1)),
                  SizedBox(height: 6),
                  QvEquipmentItem(
                    equipment: equipmentState.equippedEquipment,
                    onTap: () {
                      if (equipmentState.equippedEquipment != null &&
                          !equipmentState.equippedEquipment!.isEquipped) {
                        context
                            .read<EquipmentCubit>()
                            .equipEquipment(equipmentState.equippedEquipment!);
                      }
                    },
                  ),
                  SizedBox(height: 6),
                ],
              ),
            ),
            Container(
              height: 2,
              width: double.infinity,
              color: Color(0xfffff2be),
            ),
            Container(
              height: 4,
              width: double.infinity,
              color: colorScheme.primary,
            ),
            Container(
              height: 2,
              width: double.infinity,
              color: Color(0xffcaa365),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                color: colorScheme.secondary,
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  itemCount: equipmentState.equipment
                      .where((equipment) => !equipment.isEquipped)
                      .length,
                  itemBuilder: (context, index) {
                    final equipment = equipmentState.equipment
                        .where((equipment) => !equipment.isEquipped)
                        .toList()[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: QvEquipmentItem(
                        equipment: equipment,
                        onTap: () {
                          context
                              .read<EquipmentCubit>()
                              .equipEquipment(equipment);
                        },
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
