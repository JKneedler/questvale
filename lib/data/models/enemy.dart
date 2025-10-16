import 'package:questvale/data/models/enemy_data.dart';

class Enemy {
  static const String enemyTableName = 'Enemies';

  static const String idColumnName = 'id';
  static const String encounterIdColumnName = 'encounterId';
  static const String enemyDataIdColumnName = 'enemyDataId';
  static const String currentHealthColumnName = 'currentHealth';
  static const String positionColumnName = 'position';

  static const createTableSQL = '''
    CREATE TABLE $enemyTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $encounterIdColumnName VARCHAR NOT NULL,
      $enemyDataIdColumnName VARCHAR NOT NULL,
      $currentHealthColumnName INTEGER NOT NULL,
      $positionColumnName INTEGER NOT NULL
    );
  ''';

  final String id;
  final String encounterId;
  final EnemyData enemyData;
  final int currentHealth;
  final int position;

  const Enemy(
      {required this.id,
      required this.encounterId,
      required this.enemyData,
      required this.currentHealth,
      required this.position});

  Map<String, Object?> toMap() {
    return {
      idColumnName: id,
      encounterIdColumnName: encounterId,
      enemyDataIdColumnName: enemyData.id,
      currentHealthColumnName: currentHealth,
      positionColumnName: position,
    };
  }

  @override
  String toString() {
    return 'Enemy(id: $id, encounterId: $encounterId, enemyData: $enemyData, currentHealth: $currentHealth, position: $position)';
  }

  Enemy copyWith({
    String? id,
    String? encounterId,
    EnemyData? enemyData,
    int? currentHealth,
    int? position,
  }) {
    return Enemy(
      id: id ?? this.id,
      encounterId: encounterId ?? this.encounterId,
      enemyData: enemyData ?? this.enemyData,
      currentHealth: currentHealth ?? this.currentHealth,
      position: position ?? this.position,
    );
  }
}
