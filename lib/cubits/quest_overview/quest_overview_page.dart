import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/quest_overview/quest_overview_cubit.dart';
import 'package:questvale/cubits/quest_overview/quest_overview_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/models/quest_room.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/data/repositories/quest_room_repository.dart';
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
        EnemyRepository(db: context.read<Database>().database),
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
              Text(quest.allRoomsCompleted
                  ? 'Quest Completed!'
                  : 'Room ${quest.currentRoomNumber} / ${quest.rooms.length}')
            ],
          ),
        ),
        (quest.allRoomsCompleted
            ? QuestLootView()
            : RoomView(room: quest.currentRoom)),
      ],
    );
  }
}

class QuestLootView extends StatelessWidget {
  const QuestLootView({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      height: 350,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Loot',
            textAlign: TextAlign.center,
          ),
          Divider(
            color: colorScheme.onSurfaceVariant,
          ),
          Expanded(child: const SizedBox()),
          TextButton(
            onPressed: () => context.read<QuestOverviewCubit>().completeQuest(),
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2, color: colorScheme.onSurface),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                backgroundColor: colorScheme.surfaceContainerHighest),
            child: Text(
              'Return to Town',
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class RoomView extends StatelessWidget {
  final QuestRoom room;

  const RoomView({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return (room.allEnemiesDead
        ? RoomLootView()
        : ListView.builder(
            shrinkWrap: true,
            itemCount: room.enemies.length,
            itemBuilder: (context, index) {
              return EnemyTile(enemy: room.enemies[index], index: index);
            },
          ));
  }
}

class RoomLootView extends StatelessWidget {
  const RoomLootView({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      height: 350,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Loot',
            textAlign: TextAlign.center,
          ),
          Divider(
            color: colorScheme.onSurfaceVariant,
          ),
          Expanded(child: const SizedBox()),
          TextButton(
            onPressed: () => context.read<QuestOverviewCubit>().nextRoom(),
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2, color: colorScheme.onSurface),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                backgroundColor: colorScheme.surfaceContainerHighest),
            child: Text(
              'Next Room',
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class EnemyTile extends StatelessWidget {
  final Enemy enemy;
  final int index;

  const EnemyTile({super.key, required this.enemy, required this.index});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: colorScheme.surfaceContainerHighest,
        ),
        height: 100,
        child: Flex(
          direction: Axis.horizontal,
          spacing: 10,
          children: [
            SizedBox(
              width: 75,
              child: (enemy.isDead
                  ? Icon(
                      Symbols.skull,
                      fill: 1,
                      color: colorScheme.onSurface,
                      size: 30,
                    )
                  : TextButton(
                      onPressed: () =>
                          context.read<QuestOverviewCubit>().attackEnemy(index),
                      style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 2, color: colorScheme.onSurface),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          backgroundColor: colorScheme.surfaceContainerHighest),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.swords,
                            fill: 1,
                            color: colorScheme.onSurface,
                            size: 30,
                          ),
                        ],
                      ),
                    )),
            ),
            Expanded(
              child: Column(
                spacing: 4,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      enemy.name,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Colors.red, width: 2)),
                    height: 25,
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                          width: 260 * (enemy.currentHealth / enemy.maxHealth),
                        ),
                        Text('${enemy.currentHealth} / ${enemy.maxHealth}'),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.swords,
                        fill: 1,
                        color: colorScheme.onSurface,
                        size: 16,
                      ),
                      Text(
                        '${enemy.attackDamage}',
                        style: TextStyle(fontSize: 16),
                      ),
                      VerticalDivider(
                        thickness: 2,
                        color: colorScheme.onSurface,
                        indent: 1,
                        endIndent: 1,
                      ),
                      Icon(
                        Symbols.fast_forward,
                        fill: 1,
                        color: colorScheme.onSurface,
                        size: 16,
                      ),
                      Text(
                        '${enemy.attackInterval}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
