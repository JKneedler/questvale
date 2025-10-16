import 'package:questvale/data/models/quest_zone.dart';

class Quest {
  static const questTableName = 'Quests';

  static const idColumnName = 'id';
  static const characterIdColumnName = 'characterId';
  static const zoneColumnName = 'zone';
  static const numFloorsColumnName = 'numFloors';
  static const numEncountersCurFloorColumnName = 'numEncountersCurFloor';
  static const curFloorColumnName = 'curFloor';
  static const curEncounterNumColumnName = 'curEncounterNum';

  static const createTableSQL = '''
    CREATE TABLE ${Quest.questTableName}(
      ${Quest.idColumnName} VARCHAR PRIMARY KEY,
      ${Quest.characterIdColumnName} VARCHAR NOT NULL,
      ${Quest.zoneColumnName} VARCHAR NOT NULL,
      ${Quest.numFloorsColumnName} INTEGER NOT NULL,
      ${Quest.numEncountersCurFloorColumnName} INTEGER NOT NULL,
      ${Quest.curFloorColumnName} INTEGER NOT NULL,
      ${Quest.curEncounterNumColumnName} INTEGER NOT NULL
    );
  ''';

  final String id;
  final QuestZone zone;
  final String characterId;
  final int numFloors;
  final int numEncountersCurFloor;
  final int curFloor;
  final int curEncounterNum;

  Quest({
    required this.id,
    required this.zone,
    required this.characterId,
    required this.numFloors,
    required this.numEncountersCurFloor,
    required this.curFloor,
    required this.curEncounterNum,
  });

  Map<String, Object?> toMap() {
    return {
      Quest.idColumnName: id,
      Quest.zoneColumnName: zone.id,
      Quest.characterIdColumnName: characterId,
      Quest.numFloorsColumnName: numFloors,
      Quest.numEncountersCurFloorColumnName: numEncountersCurFloor,
      Quest.curFloorColumnName: curFloor,
      Quest.curEncounterNumColumnName: curEncounterNum,
    };
  }

  @override
  String toString() {
    return 'Quest(id: $id, zone: $zone, characterId: $characterId, numFloors: $numFloors, numEncountersCurFloor: $numEncountersCurFloor, curFloor: $curFloor, curEncounterNum: $curEncounterNum)';
  }

  Quest copyWith({
    QuestZone? zone,
    String? characterId,
    int? numFloors,
    int? numEncountersCurFloor,
    int? curFloor,
    int? curEncounterNum,
  }) {
    return Quest(
      id: id,
      zone: zone ?? this.zone,
      characterId: characterId ?? this.characterId,
      numFloors: numFloors ?? this.numFloors,
      numEncountersCurFloor:
          numEncountersCurFloor ?? this.numEncountersCurFloor,
      curFloor: curFloor ?? this.curFloor,
      curEncounterNum: curEncounterNum ?? this.curEncounterNum,
    );
  }
}
