class BalanceData {
  // Indexed by DifficultyLevel.index (trivial, easy, medium, hard).
  final List<int> apPerDifficulty;
  final double habitApMultiplier;
  final int dailyApSoftCap;
  final double dailyApSoftCapEfficiency;
  final int dailyApHardCap;

  BalanceData({
    required this.apPerDifficulty,
    required this.habitApMultiplier,
    required this.dailyApSoftCap,
    required this.dailyApSoftCapEfficiency,
    required this.dailyApHardCap,
  });
}
