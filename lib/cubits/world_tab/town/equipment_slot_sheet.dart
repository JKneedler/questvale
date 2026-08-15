import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/equipment_gear_up/equipment_gear_up_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/equipment_gear_up/equipment_gear_up_state.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/widgets/qv_equipment_item.dart';
import 'package:questvale/widgets/qv_fading_scrollable.dart';
import 'package:questvale/widgets/qv_picker_sheet.dart';
import 'package:sqflite/sqflite.dart';

// Opens a lightweight picker sheet for one equipment slot. Reuses
// EquipmentGearUpCubit's data layer as-is (unlike the old two-tab Gear Up
// page's full 2D overview grid, this sheet is scoped to a single slot from
// the moment it opens — see the Combat & Questing Redesign ticket) —
// onEquipmentSlotSelected is fired immediately on cubit creation instead of
// waiting for a tap on an overview grid that no longer exists.
Future<void> showEquipmentSlotSheet(
  BuildContext context, {
  required EquipmentSlot slot,
  required String label,
  int? ringSlot,
}) {
  final character = context.read<PlayerCubit>().state.character!;
  final db = context.read<Database>();
  return QvPickerSheet.showModal(
    context,
    title: label,
    body: BlocProvider<EquipmentGearUpCubit>(
      create: (context) =>
          EquipmentGearUpCubit(db: db, character: character)
            ..onEquipmentSlotSelected(slot, ringSlot: ringSlot),
      child: const _EquipmentSlotSheetBody(),
    ),
  );
}

class _EquipmentSlotSheetBody extends StatelessWidget {
  const _EquipmentSlotSheetBody();

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<EquipmentGearUpCubit, EquipmentGearUpState>(
      builder: (context, state) {
        final cubit = context.read<EquipmentGearUpCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Currently Equipped',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 6),
            QvEquipmentItem(
              equipment: cubit.selectedSlotEquippedItem,
              isEquipped: true,
              showName: true,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: state.inventoryEquipment.isEmpty
                  ? Center(
                      child: Text(
                        'No other gear for this slot',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  : QvFadingScrollable(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 10),
                        itemCount: state.inventoryEquipment.length,
                        itemBuilder: (context, index) {
                          final equipment = state.inventoryEquipment[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: QvEquipmentItem(
                              equipment: equipment,
                              isEquipped: false,
                              showName: true,
                              onTap: () async {
                                await cubit.equipEquipment(equipment);
                                if (!context.mounted) return;
                                context.read<PlayerCubit>().loadCharacter();
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
