import 'package:questvale/data/models/quest.dart';
import 'package:sqflite/sqflite.dart';

class QuestRepository {
  final Database db;

  QuestRepository({required this.db});

  /*

  --------------------------- Quest ---------------------------------

  */

  // GET QUEST BY CHARACTER ID
  Future<Quest?> getQuest(String characterId) async {
    final result = await db.query(Quest.questTableName,
        where: '${Quest.characterIdColumnName} = ?', whereArgs: [characterId]);
    if (result.length > 1) {
      throw Exception('Multiple quests found for character $characterId');
    } else if (result.isEmpty) {
      return null;
    }

    final quest = await _getQuestFromMap(result[0]);
    return quest;
  }

  // GET NUMBER OF QUEST BY CHARACTER ID
  Future<int> getQuestsNum() async {
    final result = await db.query(Quest.questTableName);
    print(result);
    return result.length;
  }

  // INSERT QUEST
  Future<void> insertQuest(Quest quest) async {
    await db.insert(Quest.questTableName, quest.toMap());
  }

  // UPDATE QUEST
  Future<Quest?> updateQuest(Quest quest) async {
    await db.update(Quest.questTableName, quest.toMap(),
        where: '${Quest.idColumnName} = ?', whereArgs: [quest.id]);
    final updatedQuest = await getQuest(quest.characterId);
    return updatedQuest;
  }

  // DELETE QUEST
  Future<void> deleteQuest(Quest quest) async {
    await db.delete(Quest.questTableName,
        where: '${Quest.idColumnName} = ?', whereArgs: [quest.id]);
  }

  // DELETE ALL QUESTS
  Future<void> deleteQuests() async {
    await db.delete(Quest.questTableName);
  }

  // DELETE ALL QUESTS FOR CHARACTER ID
  Future<void> deleteQuestsForCharacter(String characterId) async {
    await db.delete(Quest.questTableName,
        where: '${Quest.characterIdColumnName} = ?', whereArgs: [characterId]);
  }

  // map method for quest
  Future<Quest> _getQuestFromMap(Map<String, dynamic> map) async {
    return Quest(
      id: map[Quest.idColumnName] as String,
      zoneId: map[Quest.zoneColumnName] as String,
      characterId: map[Quest.characterIdColumnName] as String,
      numFloors: map[Quest.numFloorsColumnName] as int,
      numEncountersCurFloor: map[Quest.numEncountersCurFloorColumnName] as int,
      curFloor: map[Quest.curFloorColumnName] as int,
      curEncounterNum: map[Quest.curEncounterNumColumnName] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          map[Quest.createdAtColumnName] as int),
      completedAt: map[Quest.completedAtColumnName] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map[Quest.completedAtColumnName] as int)
          : null,
    );
  }
}
