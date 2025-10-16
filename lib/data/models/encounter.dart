import 'package:questvale/data/models/enemy.dart';

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
  static const String questIdColumnName = 'questId';

  static const String createTableSQL = '''
    CREATE TABLE $encounterTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $encounterTypeColumnName INTEGER NOT NULL,
      $encounterCompletedColumnName BOOLEAN NOT NULL,
      $questIdColumnName VARCHAR NOT NULL
    );
  ''';

  final String id;
  final EncounterType encounterType;
  final bool encounterCompleted;
  final String questId;
  final List<Enemy> enemies;

  const Encounter({
    required this.id,
    required this.encounterType,
    required this.encounterCompleted,
    required this.questId,
    this.enemies = const [],
  });

  Map<String, Object?> toMap() {
    return {
      idColumnName: id,
      encounterTypeColumnName: encounterType.index,
      encounterCompletedColumnName: encounterCompleted ? 1 : 0,
      questIdColumnName: questId,
    };
  }

  @override
  String toString() {
    return 'Encounter(id: $id, encounterType: $encounterType, encounterCompleted: $encounterCompleted, questId: $questId, enemies: $enemies)';
  }

  Encounter copyWith({
    String? id,
    EncounterType? encounterType,
    bool? encounterCompleted,
    String? questId,
    List<Enemy>? enemies,
  }) {
    return Encounter(
      id: id ?? this.id,
      encounterType: encounterType ?? this.encounterType,
      encounterCompleted: encounterCompleted ?? this.encounterCompleted,
      questId: questId ?? this.questId,
      enemies: enemies ?? this.enemies,
    );
  }
}
