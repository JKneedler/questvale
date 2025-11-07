import 'package:questvale/data/models/enemy.dart';
import 'package:sqflite/sqflite.dart';

class EnemyRepository {
  final Database db;

  EnemyRepository({required this.db});

  /*

    --------------------------- Enemy ---------------------------------

  */

  // GET ENEMIES BY ENCOUNTER ID
  Future<List<Enemy>> getEnemiesByEncounterId(String encounterId) async {
    final List<Map<String, dynamic>> maps = await db.query(Enemy.enemyTableName,
        where: 'encounterId = ?', whereArgs: [encounterId]);
    List<Enemy> enemies = [];
    for (var map in maps) {
      enemies.add(await _getEnemyFromMap(map));
    }
    enemies.sort((a, b) => a.position.compareTo(b.position));
    return enemies.toList();
  }

  // GET ENEMY BY ID
  Future<Enemy> getEnemyById(String enemyId) async {
    final result = await db.query(Enemy.enemyTableName,
        where: '${Enemy.idColumnName} = ?', whereArgs: [enemyId]);
    if (result.isEmpty) {
      throw Exception('Enemy $enemyId not found');
    }
    return _getEnemyFromMap(result[0]);
  }

  // GET NUMBER OF TOTAL ENEMIES
  Future<int> getEnemiesNum() async {
    final result = await db.query(Enemy.enemyTableName);
    return result.length;
  }

  // UPDATE ENEMY
  Future<void> updateEnemy(Enemy enemy) async {
    await db.update(Enemy.enemyTableName, enemy.toMap(),
        where: '${Enemy.idColumnName} = ?', whereArgs: [enemy.id]);
  }

  // INSERT ENEMY
  Future<void> insertEnemy(Enemy enemy) async {
    await db.insert(Enemy.enemyTableName, enemy.toMap());
  }

  // DELETE ENEMIES
  Future<void> deleteEnemies() async {
    await db.delete(Enemy.enemyTableName);
  }

  // DELETE ENEMIES BY ENCOUNTER ID
  Future<void> deleteEnemiesByEncounterId(String encounterId) async {
    await db.delete(Enemy.enemyTableName,
        where: '${Enemy.encounterIdColumnName} = ?', whereArgs: [encounterId]);
  }

  // map to enemy
  Future<Enemy> _getEnemyFromMap(Map<String, Object?> map) async {
    return Enemy(
      id: map[Enemy.idColumnName] as String,
      enemyDataId: map[Enemy.enemyDataIdColumnName] as String,
      encounterId: map[Enemy.encounterIdColumnName] as String,
      currentHealth: map[Enemy.currentHealthColumnName] as int,
      position: map[Enemy.positionColumnName] as int,
    );
  }
}
