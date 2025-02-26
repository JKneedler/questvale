import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/skills_overview/skills_overview_cubit.dart';
import 'package:questvale/cubits/skills_overview/skills_overview_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_skill.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/character_skill_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math';

class SkillsOverviewPage extends StatelessWidget {
  const SkillsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SkillsOverviewCubit(
        CharacterRepository(db: context.read<Database>()),
        CharacterSkillRepository(db: context.read<Database>().database),
      ),
      child: SkillsOverviewView(),
    );
  }
}

class SkillsOverviewView extends StatelessWidget {
  const SkillsOverviewView({super.key});

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
          actions: [
            IconButton(
              icon: Icon(
                Icons.replay_outlined,
                color: colorScheme.onPrimary,
              ),
              onPressed: () =>
                  context.read<SkillsOverviewCubit>().resetSkills(),
            ),
          ]),
      backgroundColor: colorScheme.surface,
      body: BlocBuilder<SkillsOverviewCubit, SkillsOverviewState>(
          builder: (context, skillState) {
        Character? char = skillState.character;
        if (char != null) {
          final skillTiers =
              CharacterSkill.skillTiersView[char.characterClass]!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < skillTiers.length; i++)
                    SkillTierView(
                      tier: i + 1,
                      tierSkills: skillTiers[i],
                    )
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }
}

class SkillTierView extends StatelessWidget {
  final int tier;
  final List<SkillType> tierSkills;

  const SkillTierView({
    super.key,
    required this.tier,
    required this.tierSkills,
  });

  List<SkillType> _getRow(int row, List<SkillType> skills) {
    if (skills.length == 4) {
      return (row == 1 ? [skills[0], skills[1]] : [skills[2], skills[3]]);
    } else {
      return row == 1
          ? skills.sublist(0, [3, skills.length].reduce(min))
          : (skills.length < 4 ? [] : skills.sublist(3, skills.length));
    }
  }

  SkillInfo _getSkillInfoFromType(
      SkillType type, List<CharacterSkill> characterSkills) {
    final Map<String, Object> map = CharacterSkill.skillInfo[type]!;
    final bool isActive = map['isActive'] as bool;
    final int characterSkillsIndex =
        characterSkills.indexWhere((element) => element.type == type);
    return SkillInfo(
      type: type,
      name: map['name'] as String,
      description: map['description'] as String,
      icon: map['icon'] as String,
      tier: map['tier'] as int,
      curLevel: characterSkillsIndex > -1
          ? characterSkills[characterSkillsIndex].level
          : 0,
      maxLevel: map['maxLevel'] as int,
      isActive: isActive,
      damageMult: isActive ? map['damageMult'] as int : 0,
      apCost: isActive ? map['apCost'] as int : 0,
      cooldown: isActive ? map['cooldown'] as int : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final row1 = _getRow(1, tierSkills);
    final row2 = _getRow(2, tierSkills);

    return BlocBuilder<SkillsOverviewCubit, SkillsOverviewState>(
        builder: (context, skillState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Divider(),
              Container(
                width: 60,
                color: colorScheme.surface,
                child: Text(
                  'Tier $tier',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (SkillType item in row1)
                SkillIcon(
                  skillInfo:
                      _getSkillInfoFromType(item, skillState.character!.skills),
                  isSelected: skillState.selectedSkill == item,
                  onSelect: context.read<SkillsOverviewCubit>().selectSkill,
                )
            ],
          ),
          (skillState.selectedSkill != null &&
                  row1.contains(skillState.selectedSkill)
              ? SkillInfoWindow(
                  skillInfo: _getSkillInfoFromType(
                      skillState.selectedSkill!, skillState.character!.skills),
                  remainingSkillPoints: skillState.remainingSkillPoints,
                )
              : const SizedBox.shrink()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (SkillType item in row2)
                SkillIcon(
                  skillInfo:
                      _getSkillInfoFromType(item, skillState.character!.skills),
                  isSelected: skillState.selectedSkill == item,
                  onSelect: context.read<SkillsOverviewCubit>().selectSkill,
                )
            ],
          ),
          (skillState.selectedSkill != null &&
                  row2.contains(skillState.selectedSkill)
              ? SkillInfoWindow(
                  skillInfo: _getSkillInfoFromType(
                      skillState.selectedSkill!, skillState.character!.skills),
                  remainingSkillPoints: skillState.remainingSkillPoints,
                )
              : const SizedBox.shrink()),
        ],
      );
    });
  }
}

class SkillIcon extends StatelessWidget {
  final SkillInfo skillInfo;
  final bool isSelected;
  final Function(SkillType) onSelect;

  const SkillIcon({
    super.key,
    required this.skillInfo,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => onSelect(skillInfo.type),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(
              color: (isSelected
                  ? colorScheme.onSurface
                  : colorScheme.surfaceContainerHighest),
              width: 3,
            )),
        width: 80,
        height: 80,
        child: Image(
          image: AssetImage(skillInfo.icon),
        ),
      ),
    );
  }
}

class SkillInfoWindow extends StatelessWidget {
  final SkillInfo skillInfo;
  final int remainingSkillPoints;

  const SkillInfoWindow(
      {super.key, required this.skillInfo, required this.remainingSkillPoints});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          spacing: 6,
          children: [
            Text(skillInfo.name),
            Text(skillInfo.description),
            Text('Tier : ${skillInfo.tier}'),
            Text('Level : ${skillInfo.curLevel} / ${skillInfo.maxLevel}'),
            Text(skillInfo.isActive ? 'Active' : 'Passive'),
            (skillInfo.isActive
                ? Text('Damage : ${skillInfo.damageMult}')
                : const SizedBox.shrink()),
            (skillInfo.isActive
                ? Text('Damage : ${skillInfo.apCost}')
                : const SizedBox.shrink()),
            (skillInfo.isActive
                ? Text('Damage : ${skillInfo.cooldown}')
                : const SizedBox.shrink()),
            GestureDetector(
              onTap: () => context
                  .read<SkillsOverviewCubit>()
                  .upgradeSkill(skillInfo.type),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  color: colorScheme.surfaceContainerLow,
                ),
                width: 120,
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  'Upgrade ($remainingSkillPoints)',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SkillInfo {
  final SkillType type;
  final String name;
  final String description;
  final String icon;
  final int tier;
  final int curLevel;
  final int maxLevel;
  final bool isActive;
  final int damageMult;
  final int apCost;
  final int cooldown;

  const SkillInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.tier,
    required this.curLevel,
    required this.maxLevel,
    required this.isActive,
    required this.damageMult,
    required this.apCost,
    required this.cooldown,
  });
}
