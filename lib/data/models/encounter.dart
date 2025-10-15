enum EncounterType {
  genericCombat,
  miniBoss,
  finalBoss,
  playerAmbush,
  enemyAmbush,
  chest,
  shrine,
  campfire,
}

class Encounter {
  static const String encounterTableName = 'Encounters';

  static const String idColumnName = 'id';
  static const String encounterTypeColumnName = 'encounterType';
  static const String encounterCompletedColumnName = 'encounterCompleted';

  static const String createTableSQL = '''
    CREATE TABLE $encounterTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $encounterTypeColumnName INTEGER NOT NULL,
      $encounterCompletedColumnName BOOLEAN NOT NULL
    );
  ''';

  final String id;
  final EncounterType encounterType;
  final bool encounterCompleted;

  const Encounter(
      {required this.id,
      required this.encounterType,
      required this.encounterCompleted});

  Map<String, Object?> toMap() {
    return {
      idColumnName: id,
      encounterTypeColumnName: encounterType.index,
      encounterCompletedColumnName: encounterCompleted,
    };
  }

  @override
  String toString() {
    return 'Encounter(id: $id, encounterType: $encounterType, encounterCompleted: $encounterCompleted)';
  }

  Encounter copyWith({
    String? id,
    EncounterType? encounterType,
    bool? encounterCompleted,
  }) {
    return Encounter(
      id: id ?? this.id,
      encounterType: encounterType ?? this.encounterType,
      encounterCompleted: encounterCompleted ?? this.encounterCompleted,
    );
  }
}
