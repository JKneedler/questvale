import 'package:equatable/equatable.dart';

// The result of rolling an exp gain into a (possibly multi-step) level-up —
// see the Skills UI ticket's subtask 1. Pure value holder, no DB access;
// LevelingService.applyExp computes one of these and the caller is
// responsible for persisting it onto Character.
class LevelUpResult extends Equatable {
  final int level;
  final int currentExp;
  final int skillPointsGained;

  const LevelUpResult({
    required this.level,
    required this.currentExp,
    required this.skillPointsGained,
  });

  bool get leveledUp => skillPointsGained > 0;

  @override
  List<Object?> get props => [level, currentExp, skillPointsGained];
}

// Deliberately not a DB-touching service (no constructor params, no
// repository) — same "pure static logic" split used by ApRewardService and
// CombatService's static methods, so the level-up math is unit-testable
// without a database and callers stay in control of when/how the result is
// persisted.
class LevelingService {
  // exp needed to go from `level` to `level + 1`. This is the same
  // placeholder curve combat_status_card.dart's XP bar already displays
  // (level * 100) — reused rather than replaced. Real curve design is
  // separate balance work (see the Skills UI ticket's out-of-scope note).
  static int expForLevel(int level) => level * 100;

  // Rolls `expGained` into `currentExp`, applying as many level-ups as the
  // gain covers in one pass (a single large reward — e.g. a chest — can
  // cross more than one threshold) rather than getting stuck mid-level.
  // Leftover exp past a threshold carries into the next level rather than
  // being discarded.
  static LevelUpResult applyExp({
    required int level,
    required int currentExp,
    required int expGained,
  }) {
    var newLevel = level;
    var newExp = currentExp + expGained;
    var skillPointsGained = 0;

    var threshold = expForLevel(newLevel);
    while (threshold > 0 && newExp >= threshold) {
      newExp -= threshold;
      newLevel += 1;
      skillPointsGained += 1;
      threshold = expForLevel(newLevel);
    }

    return LevelUpResult(
      level: newLevel,
      currentExp: newExp,
      skillPointsGained: skillPointsGained,
    );
  }
}
