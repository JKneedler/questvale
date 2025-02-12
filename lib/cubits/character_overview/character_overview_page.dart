import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character_overview/character_overview_cubit.dart';
import 'package:questvale/cubits/character_overview/character_overview_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/main_drawer.dart';
import 'package:sqflite/sqflite.dart';

class CharacterOverviewPage extends StatelessWidget {
  const CharacterOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CharacterOverviewCubit(
          CharacterRepository(db: context.read<Database>())),
      child: CharacterOverviewView(),
    );
  }
}

class CharacterOverviewView extends StatelessWidget {
  const CharacterOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Character',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      backgroundColor: colorScheme.surface,
      body: BlocBuilder<CharacterOverviewCubit, CharacterOverviewState>(
          builder: (context, characterState) {
        Character? char = characterState.character;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CharacterInfoTile(name: 'Name', value: '${char?.name}'),
              CharacterInfoTile(name: 'Level', value: '${char?.level}'),
              CharacterInfoTile(
                  name: 'Experience', value: '${char?.currentExp} / 50'),
              CharacterInfoTile(
                  name: 'Health',
                  value: '${char?.currentHealth} / ${char?.maxHealth}'),
              CharacterInfoTile(
                  name: 'Mana',
                  value: '${char?.currentMana} / ${char?.maxMana}')
            ],
          ),
        );
      }),
      drawer: MainDrawer(),
    );
  }
}

class CharacterInfoTile extends StatelessWidget {
  final String name;
  final String value;

  const CharacterInfoTile({super.key, required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 60,
      child: Container(
        padding: EdgeInsets.only(left: 30, right: 30),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Row(
          spacing: 10,
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 20),
            ),
            VerticalDivider(
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            Text(
              value,
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
