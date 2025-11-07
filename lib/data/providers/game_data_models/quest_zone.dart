import 'package:questvale/data/providers/game_data_models/enemy_data.dart';

class QuestZone {
  static const questZoneTableName = 'QuestZones';

  static const idColumnName = 'id';
  static const nameColumnName = 'name';
  static const requiredLevelColumnName = 'requiredLevel';
  static const maxLevelColumnName = 'maxLevel';
  static const minFloorsColumnName = 'minFloors';
  static const maxFloorsColumnName = 'maxFloors';
  static const minEncountersPerFloorColumnName = 'minEncountersPerFloor';
  static const maxEncountersPerFloorColumnName = 'maxEncountersPerFloor';
  static const minGoldColumnName = 'minGold';
  static const maxGoldColumnName = 'maxGold';
  static const experienceColumnName = 'experience';

  static const createTableSQL = '''
    CREATE TABLE ${QuestZone.questZoneTableName}(
      ${QuestZone.idColumnName} VARCHAR PRIMARY KEY,
      ${QuestZone.nameColumnName} VARCHAR NOT NULL,
      ${QuestZone.requiredLevelColumnName} INTEGER NOT NULL,
      ${QuestZone.maxLevelColumnName} INTEGER NOT NULL,
      ${QuestZone.minFloorsColumnName} INTEGER NOT NULL,
      ${QuestZone.maxFloorsColumnName} INTEGER NOT NULL,
      ${QuestZone.minEncountersPerFloorColumnName} INTEGER NOT NULL,
      ${QuestZone.maxEncountersPerFloorColumnName} INTEGER NOT NULL,
      ${QuestZone.minGoldColumnName} INTEGER NOT NULL,
      ${QuestZone.maxGoldColumnName} INTEGER NOT NULL,
      ${QuestZone.experienceColumnName} INTEGER NOT NULL
    );
  ''';

  final String id;
  final String name;
  final int requiredLevel;
  final int maxLevel;
  final int minFloors;
  final int maxFloors;
  final int minEncountersPerFloor;
  final int maxEncountersPerFloor;
  final int minGold;
  final int maxGold;
  final int experience;
  final List<EnemyData> enemies;

  QuestZone({
    required this.id,
    required this.name,
    required this.requiredLevel,
    required this.maxLevel,
    required this.minFloors,
    required this.maxFloors,
    required this.minEncountersPerFloor,
    required this.maxEncountersPerFloor,
    required this.minGold,
    required this.maxGold,
    required this.experience,
    this.enemies = const [],
  });

  Map<String, Object?> toMap() {
    return {
      QuestZone.idColumnName: id,
      QuestZone.nameColumnName: name,
      QuestZone.requiredLevelColumnName: requiredLevel,
      QuestZone.maxLevelColumnName: maxLevel,
      QuestZone.minFloorsColumnName: minFloors,
      QuestZone.maxFloorsColumnName: maxFloors,
      QuestZone.minEncountersPerFloorColumnName: minEncountersPerFloor,
      QuestZone.maxEncountersPerFloorColumnName: maxEncountersPerFloor,
      QuestZone.minGoldColumnName: minGold,
      QuestZone.maxGoldColumnName: maxGold,
      QuestZone.experienceColumnName: experience,
    };
  }

  @override
  String toString() {
    return 'QuestZone(id: $id, name: $name, requiredLevel: $requiredLevel, maxLevel: $maxLevel, minFloors: $minFloors, maxFloors: $maxFloors, minEncountersPerFloor: $minEncountersPerFloor, maxEncountersPerFloor: $maxEncountersPerFloor, minGold: $minGold, maxGold: $maxGold, experience: $experience, enemies: $enemies)';
  }

  QuestZone copyWith({
    String? name,
    int? requiredLevel,
    int? maxLevel,
    int? minFloors,
    int? maxFloors,
    int? minEncountersPerFloor,
    int? maxEncountersPerFloor,
    int? minGold,
    int? maxGold,
    int? experience,
    List<EnemyData>? enemies,
  }) {
    return QuestZone(
      id: id,
      name: name ?? this.name,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      maxLevel: maxLevel ?? this.maxLevel,
      minFloors: minFloors ?? this.minFloors,
      maxFloors: maxFloors ?? this.maxFloors,
      minEncountersPerFloor:
          minEncountersPerFloor ?? this.minEncountersPerFloor,
      maxEncountersPerFloor:
          maxEncountersPerFloor ?? this.maxEncountersPerFloor,
      minGold: minGold ?? this.minGold,
      maxGold: maxGold ?? this.maxGold,
      experience: experience ?? this.experience,
      enemies: enemies ?? this.enemies,
    );
  }
}
