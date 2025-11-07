class Enemy {
  static const String enemyTableName = 'Enemies';

  static const String idColumnName = 'id';
  static const String enemyDataIdColumnName = 'enemyDataId';
  static const String encounterIdColumnName = 'encounterId';
  static const String currentHealthColumnName = 'currentHealth';
  static const String positionColumnName = 'position';

  static const createTableSQL = '''
    CREATE TABLE $enemyTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $enemyDataIdColumnName VARCHAR NOT NULL,
      $encounterIdColumnName VARCHAR NOT NULL,
      $currentHealthColumnName INTEGER NOT NULL,
      $positionColumnName INTEGER NOT NULL
    );
  ''';

  final String id;
  final String enemyDataId;
  final String encounterId;
  final int currentHealth;
  final int position;

  const Enemy(
      {required this.id,
      required this.enemyDataId,
      required this.encounterId,
      required this.currentHealth,
      required this.position});

  Map<String, Object?> toMap() {
    return {
      idColumnName: id,
      enemyDataIdColumnName: enemyDataId,
      encounterIdColumnName: encounterId,
      currentHealthColumnName: currentHealth,
      positionColumnName: position,
    };
  }

  @override
  String toString() {
    return 'Enemy(id: $id, enemyDataId: $enemyDataId, encounterId: $encounterId, currentHealth: $currentHealth, position: $position)';
  }

  Enemy copyWith({
    String? id,
    String? enemyDataId,
    String? encounterId,
    int? currentHealth,
    int? position,
  }) {
    return Enemy(
      id: id ?? this.id,
      enemyDataId: enemyDataId ?? this.enemyDataId,
      encounterId: encounterId ?? this.encounterId,
      currentHealth: currentHealth ?? this.currentHealth,
      position: position ?? this.position,
    );
  }
}
