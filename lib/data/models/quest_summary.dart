class QuestSummary {
  static const questSummaryTableName = 'QuestSummaries';

  static const idColumnName = 'id';
  static const questIdColumnName = 'questId';
  static const xpColumnName = 'xp';
  static const goldColumnName = 'gold';

  static const createTableSQL = '''
    CREATE TABLE $questSummaryTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $questIdColumnName VARCHAR NOT NULL,
      $xpColumnName INTEGER NOT NULL,
      $goldColumnName INTEGER NOT NULL
    );
  ''';

  final String id;
  final String questId;
  final int xp;
  final int gold;

  const QuestSummary({
    required this.id,
    required this.questId,
    required this.xp,
    required this.gold,
  });

  Map<String, Object?> toMap() {
    return {
      QuestSummary.idColumnName: id,
      QuestSummary.questIdColumnName: questId,
      QuestSummary.xpColumnName: xp,
      QuestSummary.goldColumnName: gold,
    };
  }

  @override
  String toString() {
    return 'QuestSummary(id: $id, questId: $questId, xp: $xp, gold: $gold)';
  }

  QuestSummary copyWith({
    String? id,
    String? questId,
    int? xp,
    int? gold,
  }) {
    return QuestSummary(
      id: id ?? this.id,
      questId: questId ?? this.questId,
      xp: xp ?? this.xp,
      gold: gold ?? this.gold,
    );
  }
}
