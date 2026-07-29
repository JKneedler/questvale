import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/providers/game_data.dart';

// AP-per-difficulty and the daily earning cap are deliberately configurable
// (data/balance.json) — the vault's Tasks & Habits design doc leaves the
// exact numbers undecided, only that difficulty scales AP, habits earn
// somewhat less than tasks, and the daily cap should have a low soft cap and
// a very high hard cap. Streak-based AP scaling is explicitly flagged as
// "not yet decided" there too, so it isn't implemented here.
class ApRewardService {
  final GameData gameData;

  ApRewardService({required this.gameData});

  int apForCompletion(DifficultyLevel difficulty, bool isHabit) {
    final base = gameData.balance.apPerDifficulty[difficulty.index];
    if (!isHabit) return base;
    return (base * gameData.balance.habitApMultiplier).floor();
  }

  // How much of `character`'s dailyApEarned still counts, given it only
  // tracks a single day and resets whenever that day has passed.
  int currentDailyEarned(Character character) {
    final earnedDate = character.dailyApEarnedDate;
    if (earnedDate == null || !_isToday(earnedDate)) return 0;
    return character.dailyApEarned;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Separate from the in-quest AP holding cap (see Action Points.md) — this
  // governs how much AP can be *earned* per day from Tasks/Habits. Full
  // efficiency up to the soft cap, reduced efficiency between the soft and
  // hard cap, nothing beyond the hard cap. A single reward can straddle the
  // soft-cap boundary, so it's split rather than judged as all-or-nothing.
  int applyDailyCap(int alreadyEarnedToday, int rawAmount) {
    final softCap = gameData.balance.dailyApSoftCap;
    final hardCap = gameData.balance.dailyApHardCap;
    final efficiency = gameData.balance.dailyApSoftCapEfficiency;

    if (alreadyEarnedToday >= hardCap || rawAmount <= 0) return 0;

    final capacityBeforeHardCap = hardCap - alreadyEarnedToday;
    final rawCapped =
        rawAmount > capacityBeforeHardCap ? capacityBeforeHardCap : rawAmount;

    if (alreadyEarnedToday >= softCap) {
      return (rawCapped * efficiency).floor();
    }

    final capacityAtFullEfficiency = softCap - alreadyEarnedToday;
    if (rawCapped <= capacityAtFullEfficiency) {
      return rawCapped;
    }

    final reducedPortion = rawCapped - capacityAtFullEfficiency;
    return capacityAtFullEfficiency + (reducedPortion * efficiency).floor();
  }
}
