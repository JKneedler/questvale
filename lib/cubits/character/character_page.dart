import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character/character_cubit.dart';
import 'package:questvale/cubits/character/character_state.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:questvale/widgets/qv_inset_background.dart';
import 'package:questvale/widgets/qv_primary_border.dart';
import 'package:sqflite/sqflite.dart';

class CharacterPage extends StatelessWidget {
  const CharacterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CharacterCubit>(
      create: (context) => CharacterCubit(db: context.read<Database>()),
      child: CharacterView(),
    );
  }
}

class CharacterView extends StatelessWidget {
  const CharacterView({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    const scaffoldPadding = 6.0;

    const gridSpacing = 6.0;

    return BlocBuilder<CharacterCubit, CharacterState>(
      builder: (context, state) {
        if (state.character == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: scaffoldPadding),
            child: Column(
              children: [
                QVAppBar(title: 'Character'),
                SizedBox(
                  width:
                      MediaQuery.of(context).size.width - (scaffoldPadding * 2),
                  height: 170,
                  child: QvPrimaryBorder(
                    widthFactor: 0.97,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: colorScheme.secondary,
                    child: Column(
                      spacing: 6,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text('Level ${state.character!.level}',
                                  style: TextStyle(
                                    fontSize: 20,
                                  )),
                            ),
                            Expanded(
                                child: Text(
                              state.character!.name,
                              style: TextStyle(fontSize: 24),
                              textAlign: TextAlign.center,
                            )),
                            SizedBox(
                                width: 100,
                                child: Text(
                                  'Mage',
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.end,
                                )),
                          ],
                        ),
                        ResourceBar(
                          maxValue: 200,
                          currentValue: state.character!.currentExp,
                          color: EXP_COLOR,
                          startAlignment: Alignment.centerLeft,
                          width: double.infinity,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ResourceBar(
                              maxValue: state.character!.maxHealth,
                              currentValue: state.character!.currentHealth,
                              color: HEALTH_COLOR,
                              startAlignment: Alignment.centerLeft,
                              width: MediaQuery.of(context).size.width * 0.4,
                            ),
                            ResourceBar(
                              maxValue: state.character!.maxMana,
                              currentValue: state.character!.currentMana,
                              color: MANA_COLOR,
                              startAlignment: Alignment.centerRight,
                              width: MediaQuery.of(context).size.width * 0.4,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          spacing: 6,
                          children: [
                            HeaderInfoSlide(
                                title: 'Gold',
                                value: '1234',
                                color: GOLD_COLOR),
                            HeaderInfoSlide(
                                title: 'Action Points',
                                value: '${state.character!.attacksRemaining}',
                                color: ACTION_POINTS_COLOR),
                            HeaderInfoSlide(
                                title: 'Skill Points',
                                value: '3',
                                color: SKILL_POINTS_COLOR),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Expanded(
                  child: SizedBox(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: gridSpacing,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: gridSpacing,
                            children: [
                              // Inventory
                              Expanded(
                                flex: 6,
                                child: QvInsetBackground(
                                  type: QvInsetBackgroundType.secondary,
                                  child: Text('Inventory'),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: QvInsetBackground(
                                  type: QvInsetBackgroundType.secondary,
                                  child: Text('Materials'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: gridSpacing,
                            children: [
                              Expanded(
                                flex: 1,
                                child: QvInsetBackground(
                                  type: QvInsetBackgroundType.secondary,
                                  child: Text('Artifact'),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: QvInsetBackground(
                                  type: QvInsetBackgroundType.secondary,
                                  child: Text('Skills'),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: QvInsetBackground(
                                  type: QvInsetBackgroundType.secondary,
                                  child: Text('Potions'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: gridSpacing),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ResourceBar extends StatelessWidget {
  const ResourceBar({
    super.key,
    required this.maxValue,
    required this.currentValue,
    required this.color,
    required this.startAlignment,
    required this.width,
  });
  final int maxValue;
  final int currentValue;
  final Color color;
  final Alignment startAlignment;
  final double width;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.primary),
        color: colorScheme.surface,
      ),
      width: width,
      height: 20,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          FractionallySizedBox(
            widthFactor: currentValue / maxValue,
            child: Container(
              color: color,
              height: 20,
            ),
          ),
          SizedBox(
            height: 20,
            child: Center(
              child: Text(
                '$currentValue / $maxValue',
                style: TextStyle(fontSize: 16, color: Colors.white, height: 1),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderInfoSlide extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const HeaderInfoSlide(
      {super.key,
      required this.title,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: QvInsetBackground(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        type: QvInsetBackgroundType.surface,
        child: SizedBox(
          height: 40,
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 16, height: 1)),
              Text(value,
                  style: TextStyle(fontSize: 24, height: 1, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
