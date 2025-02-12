import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/quest_overview/quest_overview_cubit.dart';
import 'package:questvale/cubits/quest_overview/quest_overview_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/combatant_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/data/repositories/quest_room_repository.dart';
import 'package:questvale/main_drawer.dart';
import 'package:sqflite/sqflite.dart';

class QuestOverviewPage extends StatelessWidget {
  const QuestOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuestOverviewCubit(
        CharacterRepository(db: context.read<Database>().database),
        QuestRepository(db: context.read<Database>().database),
        QuestRoomRepository(db: context.read<Database>().database),
        CombatantRepository(db: context.read<Database>().database),
      ),
      child: QuestOverviewView(),
    );
  }
}

class QuestOverviewView extends StatelessWidget {
  const QuestOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    QuestOverviewCubit questOverviewCubit = context.read<QuestOverviewCubit>();
    Quest? quest = questOverviewCubit.state.quest;

    final activeQuestWidget = quest != null
        ? Text(quest.name)
        : GetQuestButton(
            onGetQuestPressed: questOverviewCubit.createQuest,
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quest',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<QuestOverviewCubit, QuestOverviewState>(
            builder: (context, questState) {
          return Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: colorScheme.surfaceContainerHighest),
                child: SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Active Quest : '),
                      questState.quest != null
                          ? Text('${questState.quest?.name}')
                          : GetQuestButton(
                              onGetQuestPressed: questOverviewCubit.createQuest,
                            )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final currentQuest = questState.quest;
                    if (currentQuest != null) {
                      return QuestView(quest: currentQuest);
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
              Builder(
                builder: (context) {
                  final currentCharacter = questState.character;
                  if (currentCharacter != null) {
                    return CharacterView(character: currentCharacter);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          );
        }),
      ),
      drawer: MainDrawer(),
    );
  }
}

class GetQuestButton extends StatelessWidget {
  final Function() onGetQuestPressed;

  const GetQuestButton({super.key, required this.onGetQuestPressed});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TextButton(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: colorScheme.onSurface, width: 1),
        ),
      ),
      onPressed: () => onGetQuestPressed(),
      child: Text(
        'Get Quest',
        style: TextStyle(color: colorScheme.onSurface),
      ),
    );
  }
}

class QuestView extends StatelessWidget {
  final Quest quest;

  const QuestView({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final combatant = quest.rooms[quest.currentRoomNumber].combatants[0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            children: [
              Text('Room ${quest.currentRoomNumber} / ${quest.rooms.length}')
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  combatant.name,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                height: 20,
                alignment: Alignment.center,
                child:
                    Text('${combatant.currentHealth} / ${combatant.maxHealth}'),
              ),
              Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sign_language,
                    color: colorScheme.onSurface,
                  ),
                  Text(
                    '${combatant.attackDamage}',
                    style: TextStyle(fontSize: 16),
                  ),
                  VerticalDivider(),
                  Icon(
                    Icons.speed,
                    color: colorScheme.onSurface,
                  ),
                  Text(
                    '${combatant.attackInterval}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}

class CharacterView extends StatelessWidget {
  final Character character;

  const CharacterView({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        TextButton(
          onPressed: () => context.read<QuestOverviewCubit>().attackCombatant(),
          style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                  side: BorderSide(width: 2, color: colorScheme.onSurface),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              backgroundColor: colorScheme.surfaceContainerHighest),
          child: Text(
            'Attack',
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 6,
              children: [
                Center(
                    child:
                        Text('${character.name} : Level ${character.level}')),
                Center(
                    child: Text(
                        'Attacks remaining : ${character.attacksRemaining}')),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  height: 20,
                  alignment: Alignment.center,
                  child: Text(
                      '${character.currentHealth} / ${character.maxHealth}'),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  height: 20,
                  alignment: Alignment.center,
                  child:
                      Text('${character.currentMana} / ${character.maxMana}'),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.yellowAccent,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  height: 20,
                  alignment: Alignment.center,
                  child: Text('${character.currentExp} / 50'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
