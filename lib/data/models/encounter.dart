import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/helpers/shared_enums.dart';

enum EncounterType {
  genericCombat,
  miniBoss,
  finalBoss,
  playerAmbush,
  enemyAmbush,
  chest,
  shrine,
  campfire;

  bool isCombatEncounter() {
    return [
      genericCombat,
      miniBoss,
      finalBoss,
      playerAmbush,
      enemyAmbush,
    ].contains(this);
  }

  bool isChestEncounter() {
    return this == chest;
  }

  bool isShrineEncounter() {
    return this == shrine;
  }

  bool isCampfireEncounter() {
    return this == campfire;
  }

  List<EncounterType> getCombatTypes() {
    return [
      genericCombat,
      miniBoss,
      finalBoss,
      playerAmbush,
      enemyAmbush,
    ];
  }

  List<EncounterType> getSpecialEncounterTypes() {
    return [chest, shrine, campfire];
  }
}

class Encounter {
  static const String encounterTableName = 'Encounters';

  static const String idColumnName = 'id';
  static const String encounterTypeColumnName = 'encounterType';
  static const String questIdColumnName = 'questId';
  static const String createdAtColumnName = 'createdAt';
  static const String completedAtColumnName = 'completedAt';
  static const String chestRarityColumnName = 'chestRarity';

  static const String createTableSQL = '''
    CREATE TABLE $encounterTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $encounterTypeColumnName INTEGER NOT NULL,
      $questIdColumnName VARCHAR NOT NULL,
      $createdAtColumnName INTEGER NOT NULL,
      $completedAtColumnName INTEGER,
      $chestRarityColumnName INTEGER
    );
  ''';

  final String id;
  final EncounterType encounterType;
  final String questId;
  final List<Enemy> enemies;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Rarity? chestRarity;

  const Encounter({
    required this.id,
    required this.encounterType,
    required this.questId,
    this.enemies = const [],
    required this.createdAt,
    this.completedAt,
    this.chestRarity,
  });

  Map<String, Object?> toMap() {
    return {
      idColumnName: id,
      encounterTypeColumnName: encounterType.index,
      questIdColumnName: questId,
      createdAtColumnName: createdAt.millisecondsSinceEpoch,
      completedAtColumnName: completedAt?.millisecondsSinceEpoch,
      chestRarityColumnName: chestRarity?.index,
    };
  }

  @override
  String toString() {
    return 'Encounter(id: $id, encounterType: $encounterType, chestRarity: $chestRarity, questId: $questId, enemies: $enemies, createdAt: $createdAt, completedAt: $completedAt)';
  }

  Encounter copyWith({
    String? id,
    EncounterType? encounterType,
    String? questId,
    List<Enemy>? enemies,
    DateTime? createdAt,
    DateTime? completedAt,
    Rarity? chestRarity,
  }) {
    return Encounter(
      id: id ?? this.id,
      encounterType: encounterType ?? this.encounterType,
      questId: questId ?? this.questId,
      enemies: enemies ?? this.enemies,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      chestRarity: chestRarity ?? this.chestRarity,
    );
  }
}
