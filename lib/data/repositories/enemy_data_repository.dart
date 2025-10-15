import 'package:questvale/data/models/enemy_attack_data.dart';
import 'package:questvale/data/models/enemy_data.dart';
import 'package:questvale/data/models/enemy_drop_data.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:sqflite/sqflite.dart';

class EnemyDataRepository {
  final Database db;

  EnemyDataRepository({required this.db});

  Future<List<EnemyData>> getEnemiesByQuestZoneId(
      String questZoneId, bool includeAttacksAndDrops) async {
    final List<Map<String, dynamic>> maps = await db.query(
        EnemyData.enemyDataTableName,
        where: 'questZoneId = ?',
        whereArgs: [questZoneId]);
    List<EnemyData> enemies = [];
    for (var map in maps) {
      enemies.add(await _getEnemyFromMap(map, includeAttacksAndDrops));
    }
    return enemies;
  }

  Future<EnemyData> _getEnemyFromMap(
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
