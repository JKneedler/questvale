import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_card_border.dart';
import 'package:questvale/widgets/qv_inset_background.dart';

class QvEquipmentItem extends StatelessWidget {
  final Equipment? equipment;
  final Function()? onTap;
  final bool isEquipped;
  final bool showEquippedTag;
  final bool changeEquippedColor;
  final bool showName;

  const QvEquipmentItem({
    super.key,
    required this.equipment,
    this.onTap,
    this.isEquipped = false,
    this.showEquippedTag = false,
    this.changeEquippedColor = false,
    this.showName = false,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final character = context.read<PlayerCubit>().state.character!;
    final isExpandedForEquippedTag = showEquippedTag && isEquipped;
    final nameHeight = showName && equipment != null ? 24.0 : 0.0;
    final cardHeight = (isExpandedForEquippedTag ? 150 : 120) + nameHeight;

    return GestureDetector(
      onTap: onTap ?? () {},
      child: QvCardBorder(
        height: cardHeight,
        widthFactor: .97,
        type: equipment == null
            ? QvCardBorderType.surface
            : QvCardBorderType.rarity,
        bgColor: equipment != null && isEquipped && changeEquippedColor
            ? colorScheme.secondary
            : colorScheme.surface,
        rarity: equipment == null ? Rarity.common : equipment!.rarity,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Builder(
          builder: (context) {
            if (equipment == null) {
              return Center(
                child: Text('Empty', style: TextStyle(fontSize: 16, height: 1)),
              );
            }
            return SizedBox(
              height: cardHeight,
              child: Column(
                children: [
                  isExpandedForEquippedTag
                      ? SizedBox(
                          height: 30,
                          child: Text('Currently Equipped',
                              style: TextStyle(
                                  fontSize: 20,
                                  height: 1,
                                  fontStyle: FontStyle.italic)),
                        )
                      : SizedBox(),
                  if (showName)
                    SizedBox(
                      height: nameHeight,
                      child: Center(
                        child: Text(
                          equipment!.itemName(
                              equipment!.type, character.characterClass),
                          style: TextStyle(fontSize: 16, height: 1),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        QvInsetBackground(
                          width: 90,
                          type: isEquipped && changeEquippedColor
                              ? QvInsetBackgroundType.surface
                              : QvInsetBackgroundType.secondary,
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Center(
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: Image.asset(
                                equipment!.iconPath(character.characterClass),
                                fit: BoxFit.fitHeight,
                                filterQuality: FilterQuality.none,
                                scale: .1,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        if (equipment!.armorValue > 0)
                          AttributeDisplay(
                            attribute: 'Armor',
                            value: '${equipment!.armorValue}',
                            isEquipped: isEquipped && changeEquippedColor,
                          ),
                        if (equipment!.attackPower > 0)
                          AttributeDisplay(
                            attribute: 'Attack',
                            value: '${equipment!.attackPower}',
                            isEquipped: isEquipped && changeEquippedColor,
                          ),
                        if (equipment!.armorValue > 0 ||
                            equipment!.attackPower > 0)
                          SizedBox(width: 6),
                        ModifiersDisplay(
                            equipment: equipment!,
                            isEquipped: isEquipped,
                            changeEquippedColor: changeEquippedColor),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class AttributeDisplay extends StatelessWidget {
  final String attribute;
  final String value;
  final bool isEquipped;
  const AttributeDisplay(
      {super.key,
      required this.attribute,
      required this.value,
      required this.isEquipped});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: QvInsetBackground(
              type: isEquipped
                  ? QvInsetBackgroundType.surface
                  : QvInsetBackgroundType.secondary,
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                      fontSize: 32, height: 1, color: colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Container(
            height: 2,
            width: 50,
            color: colorScheme.primary,
          ),
          SizedBox(height: 4),
          Text(
            attribute,
            style:
                TextStyle(fontSize: 20, height: 1, color: colorScheme.primary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ModifiersDisplay extends StatelessWidget {
  final Equipment equipment;
  final bool isEquipped;
  final bool changeEquippedColor;
  const ModifiersDisplay(
      {super.key,
      required this.equipment,
      required this.isEquipped,
      required this.changeEquippedColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: QvInsetBackground(
        type: isEquipped && changeEquippedColor
            ? QvInsetBackgroundType.surface
            : QvInsetBackgroundType.secondary,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          itemCount: equipment.statModifiers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                equipment.statModifiers[index].valueString(),
                style: TextStyle(fontSize: 16, height: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}
