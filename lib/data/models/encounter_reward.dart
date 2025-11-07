import 'package:questvale/data/models/equipment.dart';

class EncounterReward {
  static const encounterRewardTableName = 'EncounterRewards';

  static const idColumnName = 'id';
  static const encounterIdColumnName = 'encounterId';
  static const questIdColumnName = 'questId';
  static const xpColumnName = 'xp';
  static const goldColumnName = 'gold';

  static const createTableSQL = '''
    CREATE TABLE $encounterRewardTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $encounterIdColumnName VARCHAR NOT NULL,
      $questIdColumnName VARCHAR NOT NULL,
      $xpColumnName INTEGER NOT NULL,
      $goldColumnName INTEGER NOT NULL
    );
  ''';

  final String id;
  final String encounterId;
  final String questId;
  final int xp;
  final int gold;
  final List<Equipment> equipmentRewards;

  const EncounterReward({
    required this.id,
    required this.encounterId,
    required this.questId,
    required this.xp,
    required this.gold,
    required this.equipmentRewards,
  });

  Map<String, Object?> toMap() {
    return {
      idColumnName: id,
      encounterIdColumnName: encounterId,
      questIdColumnName: questId,
      xpColumnName: xp,
      goldColumnName: gold,
    };
  }

  @override
  String toString() {
    return 'EncounterReward(id: $id, encounterId: $encounterId, questId: $questId, xp: $xp, gold: $gold, equipmentRewards: $equipmentRewards)';
  }

  EncounterReward copyWith({
    String? id,
    String? encounterId,
    String? questId,
    int? xp,
    int? gold,
    List<Equipment>? equipmentRewards,
  }) {
    return EncounterReward(
      id: id ?? this.id,
      encounterId: encounterId ?? this.encounterId,
      questId: questId ?? this.questId,
      xp: xp ?? this.xp,
      gold: gold ?? this.gold,
      equipmentRewards: equipmentRewards ?? this.equipmentRewards,
    );
  }
}
