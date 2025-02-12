import 'dart:math';

import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/combatant.dart';
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

class QuestService {
  Quest generateQuest(Character character) {
    final String questId = Uuid().v1();
    final String questName =
        _sampleQuestNames[Random().nextInt(_sampleQuestNames.length)];

    final int numberOfRooms =
        Random().nextInt(1 + (_maxNumRooms - _minNumRooms)) + _minNumRooms;
    List<QuestRoom> rooms = [];
    for (int r = 0; r < numberOfRooms; r++) {
      final String questRoomId = Uuid().v1();

      final Combatant combatant = Combatant(
        id: Uuid().v1(),
        questRoomId: questRoomId,
        name: 'Goblin',
        currentHealth: 20,
        maxHealth: 20,
        attackDamage: 4,
        attackInterval: 12,
        lastAttack: '',
      );

      QuestRoom room = QuestRoom(
        id: questRoomId,
        questId: questId,
        roomNumber: r,
        isCompleted: false,
        combatants: [combatant],
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
      currentRoomNumber: 1,
    );
  }
}
