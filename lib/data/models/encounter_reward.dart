class EncounterReward {
  static const encounterRewardTableName = 'EncounterRewards';

  static const idColumnName = 'id';
  static const encounterIdColumnName = 'encounterId';
  static const questIdColumnName = 'questId';
  static const xpColumnName = 'xp';
  static const goldColumnName = 'gold';
  static const createdAtColumnName = 'createdAt';

  static const createTableSQL = '''
    CREATE TABLE $encounterRewardTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $encounterIdColumnName VARCHAR NOT NULL,
      $questIdColumnName VARCHAR NOT NULL,
      $xpColumnName INTEGER NOT NULL,
      $goldColumnName INTEGER NOT NULL,
      $createdAtColumnName INTEGER NOT NULL
    );
  ''';

  final String id;
  final String encounterId;
  final String questId;
  final int xp;
  final int gold;
  final DateTime createdAt;

  const EncounterReward({
    required this.id,
    required this.encounterId,
    required this.questId,
    required this.xp,
    required this.gold,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      idColumnName: id,
      encounterIdColumnName: encounterId,
      questIdColumnName: questId,
      xpColumnName: xp,
      goldColumnName: gold,
      createdAtColumnName: createdAt.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'EncounterReward(id: $id, encounterId: $encounterId, questId: $questId, xp: $xp, gold: $gold, createdAt: $createdAt)';
  }

  EncounterReward copyWith({
    String? id,
    String? encounterId,
    String? questId,
    int? xp,
    int? gold,
    DateTime? createdAt,
  }) {
    return EncounterReward(
      id: id ?? this.id,
      encounterId: encounterId ?? this.encounterId,
      questId: questId ?? this.questId,
      xp: xp ?? this.xp,
      gold: gold ?? this.gold,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
