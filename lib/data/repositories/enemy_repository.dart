import 'package:questvale/data/models/enemy.dart';
import 'package:sqflite/sqflite.dart';

class EnemyRepository {
  final Database db;

  EnemyRepository({required this.db});

  // GET by id
  Future<Enemy> getEnemyById(String id) async {
    final enemyMap = await db.query(
      Enemy.enemyTableName,
      where: '${Enemy.idColumnName} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return _getEnemyFromMap(enemyMap[0]);
  }

  // GET by questRoomId
  Future<List<Enemy>> getEnemiesByQuestRoomId(String id) async {
    final enemyMaps = await db.query(
      Enemy.enemyTableName,
      where: '${Enemy.questRoomColumnName} = ?',
      whereArgs: [id],
    );
    final enemies = [for (final map in enemyMaps) _getEnemyFromMap(map)];
    return enemies;
  }

  // CREATE
  Future<void> addEnemy(Enemy enemy) async {
    await db.insert(
      Enemy.enemyTableName,
      enemy.toMap(),
    );
  }

  // UPDATE
  Future<void> updateEnemy(Enemy updateEnemy) async {
    await db.update(
      Enemy.enemyTableName,
      updateEnemy.toMap(),
      where: '${Enemy.idColumnName} = ?',
      whereArgs: [updateEnemy.id],
    );
  }

  Enemy _getEnemyFromMap(Map<String, Object?> map) {
    return Enemy(
      id: map[Enemy.idColumnName] as String,
      questRoomId: map[Enemy.questRoomColumnName] as String,
      name: map[Enemy.nameColumnName] as String,
      currentHealth: map[Enemy.currentHealthColumnName] as int,
      maxHealth: map[Enemy.maxHealthColumnName] as int,
      attackDamage: map[Enemy.attackDamageColumnName] as int,
      attackInterval: map[Enemy.attackIntervalColumnName] as int,
      lastAttack: map[Enemy.lastAttackColumnName] as String,
    );
  }
}
