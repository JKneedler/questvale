import 'package:questvale/helpers/shared_enums.dart';

enum DropItemUseCase {
  material,
  alchemy,
  blacksmithing,
  gemsmithing,
  crafting,
}

class EnemyDropData {
  static const enemyDropDataTableName = 'EnemyDropData';

  static const idColumnName = 'id';
  static const enemyIdColumnName = 'enemyId';
  static const itemNameColumnName = 'itemName';
  static const itemQuantityMinColumnName = 'itemQuantityMin';
  static const itemQuantityMaxColumnName = 'itemQuantityMax';
  static const useCasesColumnName = 'useCases';
  static const rarityColumnName = 'rarity';
  static const dropChanceColumnName = 'dropChance';

  static const createTableSQL = '''
    CREATE TABLE $enemyDropDataTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $enemyIdColumnName VARCHAR NOT NULL,
      $itemNameColumnName VARCHAR NOT NULL,
      $itemQuantityMinColumnName INTEGER NOT NULL,
      $itemQuantityMaxColumnName INTEGER NOT NULL,
      $useCasesColumnName VARCHAR NOT NULL,
      $rarityColumnName INTEGER NOT NULL,
      $dropChanceColumnName DOUBLE NOT NULL
    );
  ''';

  final String id;
  final String? enemyId;
  final String itemName;
  final int itemQuantityMin;
  final int itemQuantityMax;
  final List<DropItemUseCase> useCases;
  final Rarity rarity;
  final double dropChance;

  const EnemyDropData({
    required this.id,
    this.enemyId,
    required this.itemName,
    required this.itemQuantityMin,
    required this.itemQuantityMax,
    required this.useCases,
    required this.rarity,
    required this.dropChance,
  });

  Map<String, Object?> toMap(String enemyId) {
    return {
      EnemyDropData.idColumnName: id,
      EnemyDropData.enemyIdColumnName: enemyId,
      EnemyDropData.itemNameColumnName: itemName,
      EnemyDropData.itemQuantityMinColumnName: itemQuantityMin,
      EnemyDropData.itemQuantityMaxColumnName: itemQuantityMax,
      EnemyDropData.useCasesColumnName: useCases.map((e) => e.index).join(','),
      EnemyDropData.rarityColumnName: rarity.index,
      EnemyDropData.dropChanceColumnName: dropChance,
    };
  }

  @override
  String toString() {
    return 'EnemyDropData(id: $id, enemyId: $enemyId, itemName: $itemName, itemQuantityMin: $itemQuantityMin, itemQuantityMax: $itemQuantityMax, useCases: $useCases, rarity: $rarity, dropChance: $dropChance)';
  }

  EnemyDropData copyWith({
    String? enemyId,
    String? itemName,
    int? itemQuantityMin,
    int? itemQuantityMax,
    List<DropItemUseCase>? useCases,
    Rarity? rarity,
    double? dropChance,
  }) {
    return EnemyDropData(
      id: id,
      enemyId: enemyId ?? this.enemyId,
      itemName: itemName ?? this.itemName,
      itemQuantityMin: itemQuantityMin ?? this.itemQuantityMin,
      itemQuantityMax: itemQuantityMax ?? this.itemQuantityMax,
      useCases: useCases ?? this.useCases,
      rarity: rarity ?? this.rarity,
      dropChance: dropChance ?? this.dropChance,
    );
  }
}
