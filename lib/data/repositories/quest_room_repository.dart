import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/quest_room.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:sqflite/sqflite.dart';

class QuestRoomRepository {
  final Database db;

  late EnemyRepository enemyRepository;

  QuestRoomRepository({required this.db}) {
    enemyRepository = EnemyRepository(db: db);
  }

  // GET by id
  Future<QuestRoom> getQuestRoomById(String id) async {
    final questRoomMaps = await db.query(
      QuestRoom.questRoomTableName,
      where: '${QuestRoom.idColumnName} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return await _getQuestRoomFromMap(questRoomMaps[0]);
  }

  // GET by quest
  Future<List<QuestRoom>> getQuestRoomsByQuestId(String questId) async {
    final questRoomMaps = await db.query(
      QuestRoom.questRoomTableName,
      where: '${QuestRoom.questColumnName} = ?',
      whereArgs: [questId],
    );
    final questRooms = [
      for (final map in questRoomMaps) await _getQuestRoomFromMap(map)
    ];
    return questRooms;
  }

  // INSERT quest room
  Future<void> createQuestRoom(QuestRoom questRoom) async {
    await db.insert(
      QuestRoom.questRoomTableName,
      questRoom.toMap(),
    );
    for (Enemy enemy in questRoom.enemies) {
      enemyRepository.addEnemy(enemy);
    }
  }

  // UPDATE
  Future<void> updateQuestRoom(QuestRoom updateQuestRoom) async {
    await db.update(
      QuestRoom.questRoomTableName,
      updateQuestRoom.toMap(),
      where: '${QuestRoom.idColumnName} = ?',
      whereArgs: [updateQuestRoom.id],
    );
  }

  Future<QuestRoom> _getQuestRoomFromMap(Map<String, Object?> map) async {
    final questRoom = QuestRoom(
      id: map[QuestRoom.idColumnName] as String,
      questId: map[QuestRoom.questColumnName] as String,
      roomNumber: map[QuestRoom.roomNumberColumnName] as int,
      isCompleted:
          map[QuestRoom.isCompletedColumnName] as int == 1 ? true : false,
      enemies: [],
    );
    final initialEnemies =
        await enemyRepository.getEnemiesByQuestRoomId(questRoom.id);
    final enemies = [
      for (Enemy enemy in initialEnemies) enemy.copyWith(questRoom: questRoom)
    ];
    return questRoom.copyWith(enemies: enemies);
  }
}
