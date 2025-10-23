import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/enemy_attack_data.dart';
import 'package:questvale/data/models/enemy_data.dart';
import 'package:questvale/data/models/enemy_drop_data.dart';
import 'package:questvale/helpers/shared_enums.dart';
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
    final enemyDataId = map[Enemy.enemyDataIdColumnName] as String;
    final enemyData = await getEnemyDataById(enemyDataId, true);
    return Enemy(
      id: map[Enemy.idColumnName] as String,
      encounterId: map[Enemy.encounterIdColumnName] as String,
      enemyData: enemyData,
      currentHealth: map[Enemy.currentHealthColumnName] as int,
      position: map[Enemy.positionColumnName] as int,
    );
  }

  /*

    --------------------------- EnemyData ---------------------------------

  */

  // GET ENEMY DATA BY QUEST ZONE ID
  Future<List<EnemyData>> getEnemyDatasByQuestZoneId(
      String questZoneId, bool includeAttacksAndDrops) async {
    final List<Map<String, dynamic>> maps = await db.query(
        EnemyData.enemyDataTableName,
        where: 'questZoneId = ?',
        whereArgs: [questZoneId]);
    List<EnemyData> enemies = [];
    for (var map in maps) {
      enemies.add(await _getEnemyDataFromMap(map, includeAttacksAndDrops));
    }
    return enemies;
  }

  // GET ENEMY DATA BY ID
  Future<EnemyData> getEnemyDataById(
      String enemyDataId, bool includeAttacksAndDrops) async {
    final result = await db.query(EnemyData.enemyDataTableName,
        where: '${EnemyData.idColumnName} = ?', whereArgs: [enemyDataId]);
    if (result.isEmpty) {
      throw Exception('Enemy data $enemyDataId not found');
    }
    return _getEnemyDataFromMap(result[0], includeAttacksAndDrops);
  }

  Future<EnemyData> _getEnemyDataFromMap(
      Map<String, Object?> map, bool includeAttacksAndDrops) async {
    final enemyId = map[EnemyData.idColumnName] as String;
    List<EnemyAttackData> attacks = [];
    List<EnemyDropData> drops = [];
    if (includeAttacksAndDrops) {
      attacks = await _getEnemyAttacksFromMap(enemyId);
      drops = await _getEnemyDropsFromMap(enemyId);
    }

    return EnemyData(
      id: enemyId,
      questZoneId: map[EnemyData.questZoneIdColumnName] as String,
      name: map[EnemyData.nameColumnName] as String,
      rarity: Rarity.values[map[EnemyData.rarityColumnName] as int],
      enemyType: EnemyType.values[map[EnemyData.enemyTypeColumnName] as int],
      experience: map[EnemyData.experienceColumnName] as int,
      health: map[EnemyData.healthColumnName] as int,
      minGold: map[EnemyData.minGoldColumnName] as int,
      maxGold: map[EnemyData.maxGoldColumnName] as int,
      spawnRate: map[EnemyData.spawnRateColumnName] as double,
      immunities:
          _getDamageTypes(map[EnemyData.immunitiesColumnName] as String),
      resistances:
          _getDamageTypes(map[EnemyData.resistancesColumnName] as String),
      weaknesses:
          _getDamageTypes(map[EnemyData.weaknessesColumnName] as String),
      attacks: attacks,
      drops: drops,
    );
  }

  List<DamageType> _getDamageTypes(String typesList) {
    return typesList.isNotEmpty
        ? typesList
            .split(',')
            .map((type) => DamageType.values[int.parse(type)])
            .toList()
        : [];
  }

  Future<List<EnemyAttackData>> _getEnemyAttacksFromMap(String enemyId) async {
    final List<Map<String, dynamic>> maps = await db.query(
        EnemyAttackData.enemyAttackDataTableName,
        where: '${EnemyAttackData.enemyIdColumnName} = ?',
        whereArgs: [enemyId]);
    List<EnemyAttackData> attacks = [];
    for (var map in maps) {
      attacks.add(_getEnemyAttackFromMap(map));
    }
    return attacks;
  }

  EnemyAttackData _getEnemyAttackFromMap(Map<String, Object?> map) {
    return EnemyAttackData(
      id: map[EnemyAttackData.idColumnName] as String,
      enemyId: map[EnemyAttackData.enemyIdColumnName] as String,
      name: map[EnemyAttackData.nameColumnName] as String,
      damage: map[EnemyAttackData.damageColumnName] as int,
      damageType:
          DamageType.values[map[EnemyAttackData.damageTypeColumnName] as int],
      cooldown: map[EnemyAttackData.cooldownColumnName] as double,
      weight: map[EnemyAttackData.weightColumnName] as double,
    );
  }

  Future<List<EnemyDropData>> _getEnemyDropsFromMap(String enemyId) async {
    final List<Map<String, dynamic>> maps = await db.query(
        EnemyDropData.enemyDropDataTableName,
        where: '${EnemyDropData.enemyIdColumnName} = ?',
        whereArgs: [enemyId]);
    List<EnemyDropData> drops = [];
    for (var map in maps) {
      drops.add(_getEnemyDropFromMap(map));
    }
    return drops;
  }

  EnemyDropData _getEnemyDropFromMap(Map<String, Object?> map) {
    return EnemyDropData(
      id: map[EnemyDropData.idColumnName] as String,
      enemyId: map[EnemyDropData.enemyIdColumnName] as String,
      itemName: map[EnemyDropData.itemNameColumnName] as String,
      itemQuantityMin: map[EnemyDropData.itemQuantityMinColumnName] as int,
      itemQuantityMax: map[EnemyDropData.itemQuantityMaxColumnName] as int,
      useCases:
          _getDropItemUseCases(map[EnemyDropData.useCasesColumnName] as String),
      rarity: Rarity.values[map[EnemyDropData.rarityColumnName] as int],
      dropChance: map[EnemyDropData.dropChanceColumnName] as double,
    );
  }

  List<DropItemUseCase> _getDropItemUseCases(String useCasesList) {
    return useCasesList.isNotEmpty
        ? useCasesList
            .split(',')
            .map((useCase) => DropItemUseCase.values[int.parse(useCase)])
            .toList()
        : const [];
  }
}
