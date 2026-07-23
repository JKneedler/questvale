import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/equipment_gear_up/equipment_gear_up_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/equipment_gear_up/equipment_gear_up_state.dart';
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
        return Expanded(
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.red,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: Container(
                  color: Colors.green,
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                        child: Column(
                      children: [
                        Expanded(
                            child: Container(
                          color: Colors.yellow,
                        )),
                        Expanded(
                            child: Container(
                          color: Colors.purple,
                        )),
                      ],
                    )),
                    Expanded(
                        child: Column(
                      children: [
                        Expanded(
                            child: Container(
                          color: Colors.orange,
                        )),
                        Expanded(
                            child: Container(
                          color: Colors.pink,
                        )),
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
