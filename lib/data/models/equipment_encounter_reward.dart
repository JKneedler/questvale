class EquipmentEncounterReward {
  static const equipmentEncounterRewardTableName = 'EquipmentEncounterRewards';

  static const idColumnName = 'id';
  static const encounterRewardIdColumnName = 'encounterRewardId';
  static const equipmentIdColumnName = 'equipmentId';

  static const createTableSQL = '''
    CREATE TABLE $equipmentEncounterRewardTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $encounterRewardIdColumnName VARCHAR NOT NULL,
      $equipmentIdColumnName VARCHAR NOT NULL
    );
  ''';

  final String id;
  final String encounterRewardId;
  final String equipmentId;

  const EquipmentEncounterReward({
    required this.id,
    required this.encounterRewardId,
    required this.equipmentId,
  });

  Map<String, Object?> toMap() {
    return {
      idColumnName: id,
      encounterRewardIdColumnName: encounterRewardId,
      equipmentIdColumnName: equipmentId,
    };
  }

  @override
  String toString() {
    return 'EquipmentEncounterReward(id: $id, encounterRewardId: $encounterRewardId, equipmentId: $equipmentId)';
  }

  EquipmentEncounterReward copyWith({
    String? id,
    String? encounterRewardId,
    String? equipmentId,
  }) {
    return EquipmentEncounterReward(
      id: id ?? this.id,
      encounterRewardId: encounterRewardId ?? this.encounterRewardId,
      equipmentId: equipmentId ?? this.equipmentId,
    );
  }
}
