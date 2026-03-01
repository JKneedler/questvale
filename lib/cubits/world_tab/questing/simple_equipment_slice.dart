import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/widgets/qv_card_border.dart';
import 'package:questvale/widgets/qv_inset_background.dart';

class SimpleEquipmentSlice extends StatelessWidget {
  final Equipment equipment;
  const SimpleEquipmentSlice({super.key, required this.equipment});

  @override
  Widget build(BuildContext context) {
    final character = context.read<PlayerCubit>().state.character!;
    return QvCardBorder(
      height: 100,
      type: QvCardBorderType.rarity,
      rarity: equipment.rarity,
      padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QvInsetBackground(
            type: QvInsetBackgroundType.surface,
            child: Container(
              width: 50,
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Image.asset(
                equipment.iconPath(character.characterClass),
                filterQuality: FilterQuality.none,
                scale: .1,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(equipment.itemName(equipment.type, character.characterClass),
                  style: TextStyle(fontSize: 18, height: 1)),
              SizedBox(height: 6),
              Row(
                spacing: 4,
                children: [
                  QvInsetBackground(
                    height: 40,
                    width: 50,
                    type: QvInsetBackgroundType.surface,
                    child: Center(
                      child: Text(
                        '${equipment.attackPower > 0 ? equipment.attackPower : equipment.armorValue}',
                        style: TextStyle(fontSize: 26, height: 1),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Text(
                    equipment.attackPower > 0 ? 'Attack' : 'Armor',
                    style: TextStyle(fontSize: 24, height: 1),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
