import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character_tab/character/character_cubit.dart';
import 'package:questvale/cubits/character_tab/character/character_state.dart';
import 'package:questvale/cubits/character_tab/character_overview/character_overview_page.dart';
import 'package:questvale/cubits/character_tab/equipment/equipment_page.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/home/nav_cubit.dart';
import 'package:questvale/cubits/home/nav_state.dart';
import 'package:questvale/widgets/qv_animated_transition.dart';
import 'package:sqflite/sqflite.dart';

class CharacterPage extends StatelessWidget {
  const CharacterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final character = context.read<PlayerCubit>().state.character;
    if (character == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return BlocProvider<CharacterCubit>(
      create: (context) => CharacterCubit(
          characterId: character.id, db: context.read<Database>()),
      child: CharacterView(),
    );
  }
}

class CharacterView extends StatelessWidget {
  const CharacterView({super.key});

  Widget _getCharacterPage(BuildContext context, CharacterState state) {
    switch (state.currentLocation) {
      case CharacterPageLocation.overview:
        return CharacterOverviewPage();
      case CharacterPageLocation.equipment:
        if (state.selectedEquipmentSlot == null) {
          return SizedBox.shrink();
        }
        return EquipmentPage(equipmentSlot: state.selectedEquipmentSlot!);
      case CharacterPageLocation.skills:
        return SizedBox.shrink();
      case CharacterPageLocation.potions:
        return SizedBox.shrink();
      case CharacterPageLocation.artifacts:
        return SizedBox.shrink();
      case CharacterPageLocation.materials:
        return SizedBox.shrink();
      case CharacterPageLocation.combatStats:
        return SizedBox.shrink();
    }
  }

  QvAnimatedTransitionType _getTransitionType(
      CharacterPageLocation newLocation) {
    if (newLocation == CharacterPageLocation.overview) {
      return QvAnimatedTransitionType.slideRight;
    } else {
      return QvAnimatedTransitionType.slideLeft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterCubit, CharacterState>(
      builder: (context, state) {
        return BlocListener<NavCubit, NavState>(
          listenWhen: (prev, next) => prev.tab != 0 && next.tab == 0,
          listener: (context, navState) {
            context.read<PlayerCubit>().loadCharacter();
          },
          child: Scaffold(
            body: QvAnimatedTransition(
              duration: const Duration(milliseconds: 300),
              type: _getTransitionType(state.currentLocation),
              child: _getCharacterPage(context, state),
            ),
          ),
        );
      },
    );
  }
}
