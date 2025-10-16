import 'package:questvale/data/models/enemy_data.dart';
import 'package:questvale/data/models/quest_zone.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:sqflite/sqflite.dart';

class QuestZoneRepository {
  final Database db;

  late EnemyRepository enemyDataRepository;

  QuestZoneRepository({required this.db}) {
    enemyDataRepository = EnemyRepository(db: db);
  }

  Future<QuestZone> getQuestZone(
      String id, bool includeEnemies, bool includeVerboseEnemies) async {
    final List<Map<String, dynamic>> maps = await db.query(
      QuestZone.questZoneTableName,
      where: '${QuestZone.idColumnName} = ?',
      whereArgs: [id],
    );
    if (maps.length > 1) {
      throw Exception('Multiple quest zones found');
    }
    return _getQuestZoneFromMap(maps[0], includeEnemies, includeVerboseEnemies);
  }

  Future<List<QuestZone>> getAllQuestZones(
      bool includeEnemies, bool includeVerboseEnemies) async {
    final List<Map<String, dynamic>> maps = await db.query(
      QuestZone.questZoneTableName,
      orderBy: '${QuestZone.requiredLevelColumnName} ASC',
    );
    List<QuestZone> questZones = [];
    for (var map in maps) {
      questZones.add(await _getQuestZoneFromMap(
          map, includeEnemies, includeVerboseEnemies));
    }
    return questZones;
  }

  Future<QuestZone> _getQuestZoneFromMap(Map<String, Object?> map,
      bool includeEnemies, bool includeVerboseEnemies) async {
    List<EnemyData> enemies = [];
    if (includeEnemies) {
      enemies = await enemyDataRepository.getEnemyDatasByQuestZoneId(
          map[QuestZone.idColumnName] as String, false);
    }
    if (includeVerboseEnemies) {
      enemies = await enemyDataRepository.getEnemyDatasByQuestZoneId(
          map[QuestZone.idColumnName] as String, true);
    }

    return QuestZone(
      id: map[QuestZone.idColumnName] as String,
      name: map[QuestZone.nameColumnName] as String,
      requiredLevel: map[QuestZone.requiredLevelColumnName] as int,
      maxLevel: map[QuestZone.maxLevelColumnName] as int,
      minFloors: map[QuestZone.minFloorsColumnName] as int,
      maxFloors: map[QuestZone.maxFloorsColumnName] as int,
      minEncountersPerFloor:
          map[QuestZone.minEncountersPerFloorColumnName] as int,
      maxEncountersPerFloor:
          map[QuestZone.maxEncountersPerFloorColumnName] as int,
      minGold: map[QuestZone.minGoldColumnName] as int,
      maxGold: map[QuestZone.maxGoldColumnName] as int,
      experience: map[QuestZone.experienceColumnName] as int,
      enemies: enemies,
    );
  }
}
