import 'dart:math';

import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/models/quest_room.dart';
import 'package:uuid/uuid.dart';

const _sampleQuestNames = [
  'Complete the Dungeon',
  'Save the village',
  'Avenge the king',
  'Explore the cave',
  'Find the treasure',
  'Wipe out the enemies',
];

const _minNumRooms = 2;
const _maxNumRooms = 3;
const _minNumEnemies = 3;
const _maxNumEnemies = 3;

class QuestService {
  Quest generateQuest(Character character) {
    final String questId = Uuid().v4();
    final String questName =
        _sampleQuestNames[Random().nextInt(_sampleQuestNames.length)];

    final int numberOfRooms =
        Random().nextInt(1 + (_maxNumRooms - _minNumRooms)) + _minNumRooms;
    List<QuestRoom> rooms = [];
    for (int r = 0; r < numberOfRooms; r++) {
      final String questRoomId = Uuid().v4();
      final int numberOfEnemies =
          Random().nextInt(1 + (_maxNumEnemies - _minNumEnemies)) +
              _minNumEnemies;

      List<Enemy> enemies = [];
      for (int e = 0; e < numberOfEnemies; e++) {
        final Enemy enemy = Enemy(
          id: Uuid().v4(),
          questRoomId: questRoomId,
          name: 'Goblin',
          currentHealth: 20,
          maxHealth: 20,
          attackDamage: 4,
          attackInterval: 12,
          lastAttack: '',
        );
        enemies.add(enemy);
      }

      QuestRoom room = QuestRoom(
        id: questRoomId,
        questId: questId,
        roomNumber: r,
        isCompleted: false,
        enemies: enemies,
      );

      rooms.add(room);
    }

    return Quest(
      id: questId,
      characterId: character.id,
      character: character,
      name: questName,
      isActive: false,
      rooms: rooms,
    );
  }
}
