import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/models/quest_room.dart';
import 'package:questvale/data/repositories/quest_room_repository.dart';
import 'package:sqflite/sqflite.dart';

class QuestRepository {
  final Database db;

  late QuestRoomRepository questRoomRepository;

  QuestRepository({required this.db}) {
    questRoomRepository = QuestRoomRepository(db: db);
  }

  // GET by id
  Future<Quest> getQuestById(String id) async {
    final questMaps = await db.query(
      Quest.questTableName,
      where: '${Quest.idColumnName} = ?',
      whereArgs: [id],
    );
    return await _getQuestFromMap(questMaps[0]);
  }

  // GET all by character
  Future<List<Quest>> getQuestsByCharacterId(String id) async {
    final questMaps = await db.query(
      Quest.questTableName,
      where: '${Quest.characterColumnName} = ?',
      whereArgs: [id],
    );
    final quests = [
      for (final questMap in questMaps) await _getQuestFromMap(questMap)
    ];
    return quests;
  }

  // GET active quest by character id
  Future<Quest?> getActiveQuestByCharacterId(String id) async {
    final questMaps = await db.query(Quest.questTableName,
        where:
            '${Quest.characterColumnName} = ? AND ${Quest.isActiveColumnName} = 1',
        whereArgs: [id],
        limit: 1);
    final quest =
        questMaps.isNotEmpty ? await _getQuestFromMap(questMaps[0]) : null;
    return quest;
  }

  // ADD new quest
  Future<void> addQuest(Quest addQuest) async {
    await db.insert(
      Quest.questTableName,
      addQuest.toMap(),
    );
    for (QuestRoom questRoom in addQuest.rooms) {
      questRoomRepository.createQuestRoom(questRoom);
    }
  }

  // UPDATE
  Future<void> updateQuest(Quest updateQuest) async {
    await db.update(
      Quest.questTableName,
      updateQuest.toMap(),
      where: '${Quest.idColumnName} = ?',
      whereArgs: [updateQuest.id],
    );
  }

  Future<Quest> _getQuestFromMap(Map<String, Object?> map) async {
    final quest = Quest(
      id: map[Quest.idColumnName] as String,
      characterId: map[Quest.characterColumnName] as String,
      name: map[Quest.nameColumnName] as String,
      isActive: map[Quest.isActiveColumnName] == 1 ? true : false,
      currentRoomNumber: map[Quest.currentRoomNumberColumnName] as int,
      rooms: [],
    );
    final initialRooms =
        await questRoomRepository.getQuestRoomsByQuestId(quest.id);
    final rooms = [
      for (QuestRoom qr in initialRooms) qr.copyWith(quest: quest)
    ];
    return quest.copyWith(rooms: rooms);
  }
}
