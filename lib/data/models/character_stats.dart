// Separate from Character since this is meant to grow into a fairly
// involved tracking system over time (it's the backbone for future
// Achievement work, which already references streak length and completion
// counts) — keeping it off the core RPG-identity model avoids repeatedly
// bloating Character/its migrations as more stats get added.
class CharacterStats {
  static const characterStatsTableName = 'CharacterStats';

  static const characterIdColumnName = 'characterId';
  static const longestStreakAchievedColumnName = 'longestStreakAchieved';
  static const totalCompletedColumnName = 'totalCompleted';

  static const createTableSQL = '''
    CREATE TABLE ${CharacterStats.characterStatsTableName}(
      ${CharacterStats.characterIdColumnName} VARCHAR PRIMARY KEY,
      ${CharacterStats.longestStreakAchievedColumnName} INTEGER DEFAULT 0,
      ${CharacterStats.totalCompletedColumnName} INTEGER DEFAULT 0
    );
  ''';

  final String characterId;
  final int longestStreakAchieved;
  final int totalCompleted;

  const CharacterStats({
    required this.characterId,
    this.longestStreakAchieved = 0,
    this.totalCompleted = 0,
  });

  Map<String, Object?> toMap() {
    return {
      CharacterStats.characterIdColumnName: characterId,
      CharacterStats.longestStreakAchievedColumnName: longestStreakAchieved,
      CharacterStats.totalCompletedColumnName: totalCompleted,
    };
  }

  @override
  String toString() {
    return 'CharacterStats(characterId: $characterId, '
        'longestStreakAchieved: $longestStreakAchieved, '
        'totalCompleted: $totalCompleted)';
  }

  CharacterStats copyWith({
    int? longestStreakAchieved,
    int? totalCompleted,
  }) {
    return CharacterStats(
      characterId: characterId,
      longestStreakAchieved:
          longestStreakAchieved ?? this.longestStreakAchieved,
      totalCompleted: totalCompleted ?? this.totalCompleted,
    );
  }
}
