import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/town_tab/forging/forge/forge_cubit.dart';
import 'package:questvale/cubits/town_tab/forging/forge/forge_state.dart';
import 'package:questvale/cubits/town_tab/forging/select_equipment/select_equipment_page.dart';
import 'package:questvale/cubits/town_tab/town/town_cubit.dart';
import 'package:questvale/cubits/town_tab/town/town_state.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_animated_transition.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_card_border.dart';
import 'package:questvale/widgets/qv_inset_background.dart';
import 'package:questvale/widgets/qv_metal_corner_border.dart';
import 'package:questvale/widgets/qv_primary_border.dart';
import 'package:sqflite/sqflite.dart';

class ForgePage extends StatelessWidget {
  const ForgePage({super.key});

  @override
  Widget build(BuildContext context) {
    final character = context.read<PlayerCubit>().state.character;
    if (character == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return BlocProvider<ForgeCubit>(
      create: (context) => ForgeCubit(
        characterId: character.id,
        db: context.read<Database>(),
      ),
      child: const ForgeView(),
    );
  }
}

class ForgeView extends StatelessWidget {
  const ForgeView({super.key});

  Widget _getForgePage(BuildContext context, ForgeState forgeState) {
    switch (forgeState.currentLocation) {
      case ForgePageLocation.upgradeEquipment:
        return UpgradeView();
      case ForgePageLocation.selectEquipment:
        return SelectEquipmentPage();
    }
  }

  QvAnimatedTransitionType _getTransitionType(ForgePageLocation newLocation) {
    if (newLocation == ForgePageLocation.upgradeEquipment) {
      return QvAnimatedTransitionType.slideRight;
    } else {
      return QvAnimatedTransitionType.slideLeft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgeCubit, ForgeState>(builder: (context, forgeState) {
      return Scaffold(
        body: QvAnimatedTransition(
          duration: const Duration(milliseconds: 200),
          type: _getTransitionType(forgeState.currentLocation),
          child: _getForgePage(context, forgeState),
        ),
      );
    });
  }
}

class UpgradeView extends StatelessWidget {
  const UpgradeView({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final equipment = context.watch<ForgeCubit>().state.selectedEquipment;
    final character = context.read<PlayerCubit>().state.character!;

    final upgradeable =
        equipment != null && equipment.rarity != Rarity.legendary;

    return Container(
      color: colorScheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QvAppBar(
            title: 'Forge',
            color: colorScheme.secondary,
            insetColor: QvInsetBackgroundType.surface,
            onBackButtonPressed: () => context
                .read<TownCubit>()
                .setCurrentLocation(TownLocation.townSquare),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                children: [
                  SizedBox(
                    width: 180,
                    height: 280,
                    child: QvMetalCornerBorder(
                      color: colorScheme.surface,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 70,
                            width: 70,
                            child: RotatedBox(
                              quarterTurns: 0,
                              child: Image.asset(
                                'images/pixel-icons/hammer-simple.png',
                                filterQuality: FilterQuality.none,
                                scale: .1,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context
                                .read<ForgeCubit>()
                                .startSelectingEquipment(),
                            child: QvCardBorder(
                              height: 100,
                              width: 100,
                              padding: EdgeInsets.all(20),
                              type: equipment == null
                                  ? QvCardBorderType.surface
                                  : QvCardBorderType.rarity,
                              rarity: equipment == null
                                  ? Rarity.common
                                  : equipment.rarity,
                              bgColor: colorScheme.secondary,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  equipment == null
                                      ? Text(
                                          '+',
                                          style: TextStyle(
                                              fontSize: 60,
                                              height: 1,
                                              color: colorScheme.primary),
                                        )
                                      : Image.asset(
                                          equipment.iconPath(
                                              character.characterClass),
                                          filterQuality: FilterQuality.none,
                                          scale: .1,
                                          fit: BoxFit.fitHeight,
                                        ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 70,
                            width: 70,
                            child: Image.asset(
                              'images/pixel-icons/anvil-simple.png',
                              filterQuality: FilterQuality.none,
                              scale: .1,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Expanded(
                    child: UpgradeEquipmentInfo(equipment: equipment),
                  ),
                  SizedBox(height: 6),
                  QvButton(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.5,
                    buttonColor: ButtonColor.primary,
                    onTap: () => context.read<ForgeCubit>().upgradeEquipment(),
                    child: Center(
                      child: Text(upgradeable ? 'Upgrade' : 'Max Level',
                          style: TextStyle(
                              fontSize: 28, color: colorScheme.secondary)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpgradeEquipmentInfo extends StatelessWidget {
  final Equipment? equipment;
  const UpgradeEquipmentInfo({super.key, this.equipment});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (equipment == null) {
      return QvPrimaryBorder(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('Select a gear piece to view upgrade info',
              style: TextStyle(fontSize: 22, height: 1)),
        ),
      );
    }

    final upgradeEquipment = equipment!;
    final upgradeable = upgradeEquipment.rarity != Rarity.legendary;
    final getsNewModifier = upgradeEquipment.rarity != Rarity.legendary;

    return QvPrimaryBorder(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 12,
            children: [
              SizedBox(
                width: 140,
                child: QvButton(
                  height: 36,
                  buttonColor: ButtonColor.getColor(upgradeEquipment.rarity),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Text(
                      upgradeEquipment.rarity.name.toUpperCase(),
                      style: TextStyle(
                          fontSize: 20,
                          height: 1,
                          color: colorScheme.secondary),
                    ),
                  ),
                ),
              ),
              if (upgradeable)
                Text('->',
                    style: TextStyle(
                        fontSize: 20, height: 1, color: colorScheme.primary)),
              if (upgradeable)
                SizedBox(
                  width: 140,
                  child: QvButton(
                    height: 36,
                    buttonColor: ButtonColor.getColor(
                        Rarity.values[upgradeEquipment.rarity.index + 1]),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: Text(
                        Rarity.values[upgradeEquipment.rarity.index + 1].name
                            .toUpperCase(),
                        style: TextStyle(
                            fontSize: 20,
                            height: 1,
                            color: colorScheme.secondary),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6),
          Expanded(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: QvInsetBackground(
                        height: 50,
                        width: 50,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: getsNewModifier
                              ? upgradeEquipment.statModifiers.length + 1
                              : upgradeEquipment.statModifiers.length,
                          itemBuilder: (context, index) {
                            if (index ==
                                    upgradeEquipment.statModifiers.length &&
                                getsNewModifier) {
                              return Text('+New Random Modifier',
                                  style: TextStyle(
                                      fontSize: 18,
                                      height: 1,
                                      color: Colors.lightGreen));
                            }
                            return Text(
                              upgradeEquipment.statModifiers[index]
                                  .valueString(),
                              style: TextStyle(fontSize: 18, height: 1),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    QvInsetBackground(
                      height: 60,
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                              child: Text('Cost',
                                  style: TextStyle(fontSize: 18, height: 1))),
                          SizedBox(width: 8),
                          Container(
                              width: 2, height: 40, color: colorScheme.primary),
                          SizedBox(width: 8),
                          upgradeable
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${equipment!.rarity.goldCost} Gold',
                                      style: TextStyle(
                                        fontSize: 20,
                                        height: 1,
                                        color: GOLD_COLOR,
                                      ),
                                    ),
                                    Text(
                                      'x2 (6) Apprentice Weave',
                                      style: TextStyle(
                                        fontSize: 20,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                )
                              : Text('Max Level',
                                  style: TextStyle(fontSize: 20, height: 1))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6),
              QvInsetBackground(
                width: 75,
                child: Center(child: Text('Gem Slots')),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
