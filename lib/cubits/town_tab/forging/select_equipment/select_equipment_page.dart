import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/town_tab/forging/forge/forge_cubit.dart';
import 'package:questvale/cubits/town_tab/forging/forge/forge_state.dart';
import 'package:questvale/cubits/town_tab/forging/select_equipment/select_equipment_cubit.dart';
import 'package:questvale/cubits/town_tab/forging/select_equipment/select_equipment_state.dart';
import 'package:questvale/cubits/town_tab/town/town_cubit.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/widgets/qv_animated_transition.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_equipment_item.dart';
import 'package:questvale/widgets/qv_inset_background.dart';
import 'package:sqflite/sqflite.dart';

class SelectEquipmentPage extends StatelessWidget {
  const SelectEquipmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SelectEquipmentCubit>(
      create: (context) => SelectEquipmentCubit(
          character: context.read<TownCubit>().character,
          db: context.read<Database>()),
      child: const SelectEquipmentView(),
    );
  }
}

class SelectEquipmentView extends StatelessWidget {
  const SelectEquipmentView({super.key});

  Widget _getEquipmentSelectView(
      BuildContext context, SelectEquipmentState state) {
    if (state.equipmentSlot == null) {
      return SelectSlotView();
    }
    return EquipmentSelectView();
  }

  QvAnimatedTransitionType _getTransitionType(SelectEquipmentState state) {
    if (state.equipmentSlot == null) {
      return QvAnimatedTransitionType.slideRight;
    }
    return QvAnimatedTransitionType.slideLeft;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectEquipmentCubit, SelectEquipmentState>(
        builder: (context, state) {
      return Scaffold(
        body: QvAnimatedTransition(
          duration: const Duration(milliseconds: 200),
          type: _getTransitionType(state),
          child: _getEquipmentSelectView(context, state),
        ),
      );
    });
  }
}

class SelectSlotView extends StatelessWidget {
  const SelectSlotView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QvAppBar(
          title: 'Select Slot',
          onBackButtonPressed: () => context
              .read<ForgeCubit>()
              .setCurrentLocation(ForgePageLocation.upgradeEquipment),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SlotButton(equipmentSlot: EquipmentSlot.weapon),
              SlotButton(equipmentSlot: EquipmentSlot.head),
              SlotButton(equipmentSlot: EquipmentSlot.body),
              SlotButton(equipmentSlot: EquipmentSlot.hands),
              SlotButton(equipmentSlot: EquipmentSlot.feet),
              SlotButton(equipmentSlot: EquipmentSlot.neck),
              SlotButton(equipmentSlot: EquipmentSlot.ring),
            ],
          ),
        ),
      ],
    );
  }
}

class SlotButton extends StatelessWidget {
  final EquipmentSlot equipmentSlot;
  const SlotButton({super.key, required this.equipmentSlot});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final capitalizedName =
        equipmentSlot.name[0].toUpperCase() + equipmentSlot.name.substring(1);
    return QvButton(
      height: 60,
      width: MediaQuery.of(context).size.width * 0.5,
      onTap: () => context
          .read<SelectEquipmentCubit>()
          .onEquipmentSlotSelected(equipmentSlot),
      child: Center(
        child: Text(capitalizedName,
            style: TextStyle(
                fontSize: 22, height: 1, color: colorScheme.secondary)),
      ),
    );
  }
}

class EquipmentSelectView extends StatelessWidget {
  const EquipmentSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    final slot = context.read<SelectEquipmentCubit>().state.equipmentSlot;
    if (slot == null) {
      return const SizedBox();
    }
    final capitalizedName = slot.name[0].toUpperCase() + slot.name.substring(1);

    final equipmentList = context.watch<SelectEquipmentCubit>().state.equipment;
    return Column(
      children: [
        QvAppBar(
            title: capitalizedName,
            onBackButtonPressed: () =>
                context.read<SelectEquipmentCubit>().onClearEquipmentSlot()),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: QvInsetBackground(
              padding: EdgeInsets.symmetric(vertical: 4),
              type: QvInsetBackgroundType.secondary,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                itemCount: equipmentList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: QvEquipmentItem(
                      equipment: equipmentList[index],
                      onTap: () => context
                          .read<ForgeCubit>()
                          .onEquipmentSelected(equipmentList[index]),
                      showEquippedTag: true,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
