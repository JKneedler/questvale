import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/models/quest_summary.dart';
import 'package:questvale/data/repositories/quest_zone_repository.dart';
import 'package:sqflite/sqflite.dart';

class QuestRepository {
  final Database db;

  late QuestZoneRepository questZoneRepository;

  QuestRepository({required this.db}) {
    questZoneRepository = QuestZoneRepository(db: db);
  }

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
  Future<void> updateQuest(Quest quest) async {
    await db.update(Quest.questTableName, quest.toMap(),
        where: '${Quest.idColumnName} = ?', whereArgs: [quest.id]);
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
    final zoneId = map[Quest.zoneColumnName] as String;
    final zone = await questZoneRepository.getQuestZone(zoneId, false, false);
    return Quest(
      id: map[Quest.idColumnName] as String,
      zone: zone,
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

  /*

  --------------------------- Quest Reward ---------------------------------

  */

  // GET QUEST REWARD BY QUEST ID
  Future<QuestSummary?> getQuestSummaryByQuestId(String questId) async {
    final result = await db.query(QuestSummary.questSummaryTableName,
        where: '${QuestSummary.questIdColumnName} = ?', whereArgs: [questId]);
    if (result.isEmpty) {
      return null;
    }
    return _getQuestSummaryFromMap(result[0]);
  }

  // INSERT QUEST REWARD
  Future<void> insertQuestSummary(QuestSummary questSummary) async {
    await db.insert(QuestSummary.questSummaryTableName, questSummary.toMap());
  }

  // UPDATE QUEST REWARD
  Future<void> updateQuestSummary(QuestSummary questSummary) async {
    await db.update(QuestSummary.questSummaryTableName, questSummary.toMap(),
        where: '${QuestSummary.idColumnName} = ?',
        whereArgs: [questSummary.id]);
  }

  // DELETE QUEST REWARD
  Future<void> deleteQuestSummary(QuestSummary questSummary) async {
    await db.delete(QuestSummary.questSummaryTableName,
        where: '${QuestSummary.idColumnName} = ?',
        whereArgs: [questSummary.id]);
  }

  // DELETE QUEST REWARD BY QUEST ID
  Future<void> deleteQuestSummaryByQuestId(String questId) async {
    await db.delete(QuestSummary.questSummaryTableName,
        where: '${QuestSummary.questIdColumnName} = ?', whereArgs: [questId]);
  }

  // map method for quest reward
  QuestSummary _getQuestSummaryFromMap(Map<String, Object?> map) {
    return QuestSummary(
      id: map[QuestSummary.idColumnName] as String,
      questId: map[QuestSummary.questIdColumnName] as String,
      xp: map[QuestSummary.xpColumnName] as int,
      gold: map[QuestSummary.goldColumnName] as int,
    );
  }
}
