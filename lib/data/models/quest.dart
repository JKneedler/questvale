import 'package:questvale/data/models/quest_zone.dart';

class Quest {
  static const questTableName = 'Quests';

  static const idColumnName = 'id';
  static const zoneColumnName = 'zone';
  static const numFloorsColumnName = 'numFloors';
  static const numEncountersCurFloorColumnName = 'numEncountersCurFloor';
  static const curFloorColumnName = 'curFloor';
  static const curEncounterColumnName = 'curEncounter';
  static const curEncounterIdColumnName = 'curEncounterId';

  static const createTableSQL = '''
    CREATE TABLE ${Quest.questTableName}(
      ${Quest.idColumnName} VARCHAR PRIMARY KEY,
      ${Quest.zoneColumnName} VARCHAR NOT NULL,
      ${Quest.numFloorsColumnName} INTEGER NOT NULL,
      ${Quest.numEncountersCurFloorColumnName} INTEGER NOT NULL,
      ${Quest.curFloorColumnName} INTEGER NOT NULL,
      ${Quest.curEncounterColumnName} INTEGER NOT NULL,
      ${Quest.curEncounterIdColumnName} VARCHAR
    );
  ''';

  final String id;
  final QuestZone zone;
  final int numFloors;
  final int numEncountersCurFloor;
  final int curFloor;
  final int curEncounter;
  final String? curEncounterId;

  Quest({
    required this.id,
    required this.zone,
    required this.numFloors,
    required this.numEncountersCurFloor,
    required this.curFloor,
    required this.curEncounter,
    this.curEncounterId,
  });

  Map<String, Object?> toMap() {
    return {
      Quest.idColumnName: id,
      Quest.zoneColumnName: zone.id,
      Quest.numFloorsColumnName: numFloors,
      Quest.numEncountersCurFloorColumnName: numEncountersCurFloor,
      Quest.curFloorColumnName: curFloor,
      Quest.curEncounterColumnName: curEncounter,
      Quest.curEncounterIdColumnName: curEncounterId,
    };
  }

  @override
  String toString() {
    return 'Quest(id: $id, zone: $zone, numFloors: $numFloors, numEncountersCurFloor: $numEncountersCurFloor, curFloor: $curFloor, curEncounter: $curEncounter, curEncounterId: $curEncounterId)';
  }

  Quest copyWith({
    QuestZone? zone,
    int? numFloors,
    int? numEncountersCurFloor,
    int? curFloor,
    int? curEncounter,
    String? curEncounterId,
  }) {
    return Quest(
      id: id,
      zone: zone ?? this.zone,
      numFloors: numFloors ?? this.numFloors,
      numEncountersCurFloor:
          numEncountersCurFloor ?? this.numEncountersCurFloor,
      curFloor: curFloor ?? this.curFloor,
      curEncounter: curEncounter ?? this.curEncounter,
      curEncounterId: curEncounterId ?? this.curEncounterId,
    );
  }
}
