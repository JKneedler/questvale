import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/data/providers/game_data_models/enemy_attack_data.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/services/enemy_attack_scheduling_service.dart';

// Returns fixed values instead of real randomness, so weighted-selection
// tests are deterministic rather than statistical.
class _FixedRandom implements Random {
  final double fixedDouble;
  final int fixedInt;
  _FixedRandom({this.fixedDouble = 0, this.fixedInt = 0});

  @override
  double nextDouble() => fixedDouble;

  @override
  int nextInt(int max) => fixedInt;

  @override
  bool nextBool() => false;
}

EnemyAttackData _attack(String name, {double weight = 1.0, int damage = 3}) {
  return EnemyAttackData(
    name: name,
    damage: damage,
    damageType: DamageType.physical,
    cooldown: 8.0, // hours
    weight: weight,
  );
}

Enemy _enemy({String id = 'enemy-1'}) => Enemy(
      id: id,
      enemyDataId: 'field_rat',
      encounterId: 'encounter-1',
      currentHealth: 20,
      position: 0,
    );

void main() {
  group('selectMove', () {
    test('picks the first attack when the roll lands within its weight', () {
      final attacks = [_attack('Bite', weight: 1), _attack('Claw', weight: 3)];
      final move = EnemyAttackSchedulingService.selectMove(
          attacks, _FixedRandom(fixedDouble: 0.0));
      expect(move.name, 'Bite');
    });

    test('picks a later attack once the roll exceeds earlier weights', () {
      final attacks = [_attack('Bite', weight: 1), _attack('Claw', weight: 3)];
      // roll = 0.5 * totalWeight(4) = 2.0 — exceeds Bite's weight (1),
      // lands inside Claw's share.
      final move = EnemyAttackSchedulingService.selectMove(
          attacks, _FixedRandom(fixedDouble: 0.5));
      expect(move.name, 'Claw');
    });

    test('falls back to a uniform pick when every weight is zero', () {
      final attacks = [_attack('Bite', weight: 0), _attack('Claw', weight: 0)];
      final move = EnemyAttackSchedulingService.selectMove(
          attacks, _FixedRandom(fixedInt: 1));
      expect(move.name, 'Claw');
    });
  });

  group('buildInitialTimer', () {
    test('converts the move\'s cooldown (hours) into remainingWork/nextTriggerAt', () {
      final now = DateTime(2026, 1, 1, 12);
      final move = _attack('Bite', damage: 4);
      final timer = EnemyAttackSchedulingService.buildInitialTimer(
        enemy: _enemy(),
        encounterId: 'encounter-1',
        move: move,
        now: now,
        id: 'timer-1',
      );

      expect(timer.ownerId, 'enemy-1');
      expect(timer.encounterId, 'encounter-1');
      expect(timer.kind, ScheduledTimerKind.enemyMove);
      expect(timer.payload, 'Bite');
      expect(timer.currentRate, 1.0);
      expect(timer.remainingWorkMs, 8 * Duration.millisecondsPerHour);
      expect(timer.nextTriggerAt, now.add(const Duration(hours: 8)));
    });
  });

  group('recomputeSegment', () {
    // Mirrors the ticket's worked trace exactly: an 8h Bite timer, a Slow
    // (0.5x) applied 3h in, then Slow expiring 2h later.
    test('closes and reopens segments under an arbitrary rate, matching the worked trace', () {
      final spawn = DateTime(2026, 1, 1, 0);
      final initial = ScheduledTimer(
        id: 't1',
        ownerId: 'enemy-1',
        encounterId: 'encounter-1',
        kind: ScheduledTimerKind.enemyMove,
        payload: 'Bite',
        remainingWorkMs: 8 * Duration.millisecondsPerHour,
        segmentStartedAt: spawn,
        currentRate: 1.0,
        nextTriggerAt: spawn.add(const Duration(hours: 8)),
      );

      // T+3h: Slow starts (0.5x).
      final slowed = EnemyAttackSchedulingService.recomputeSegment(
        timer: initial,
        newRate: 0.5,
        at: spawn.add(const Duration(hours: 3)),
      );
      expect(slowed.remainingWorkMs, 5 * Duration.millisecondsPerHour);
      expect(slowed.nextTriggerAt, spawn.add(const Duration(hours: 13)));

      // T+5h: Slow expires, back to 1.0x.
      final unslowed = EnemyAttackSchedulingService.recomputeSegment(
        timer: slowed,
        newRate: 1.0,
        at: spawn.add(const Duration(hours: 5)),
      );
      expect(unslowed.remainingWorkMs, 4 * Duration.millisecondsPerHour);
      expect(unslowed.nextTriggerAt, spawn.add(const Duration(hours: 9)));
    });

    test('a rate of 0 (Freeze) halts the timer instead of dividing by zero', () {
      final spawn = DateTime(2026, 1, 1, 0);
      final initial = ScheduledTimer(
        id: 't1',
        ownerId: 'enemy-1',
        encounterId: 'encounter-1',
        kind: ScheduledTimerKind.enemyMove,
        payload: 'Bite',
        remainingWorkMs: 8 * Duration.millisecondsPerHour,
        segmentStartedAt: spawn,
        nextTriggerAt: spawn.add(const Duration(hours: 8)),
      );

      final frozen = EnemyAttackSchedulingService.recomputeSegment(
        timer: initial,
        newRate: 0,
        at: spawn.add(const Duration(hours: 1)),
      );
      expect(frozen.currentRate, 0);
      expect(frozen.nextTriggerAt.isAfter(spawn.add(const Duration(days: 300))), isTrue);
    });
  });

  group('nextDueTimer', () {
    ScheduledTimer timerAt(String id, DateTime at) => ScheduledTimer(
          id: id,
          ownerId: id,
          encounterId: 'encounter-1',
          kind: ScheduledTimerKind.enemyMove,
          payload: 'Bite',
          remainingWorkMs: 0,
          segmentStartedAt: at,
          nextTriggerAt: at,
        );

    test('returns null when nothing is overdue', () {
      final now = DateTime(2026, 1, 1);
      final timers = [timerAt('a', now.add(const Duration(hours: 1)))];
      expect(EnemyAttackSchedulingService.nextDueTimer(timers, now), isNull);
    });

    test('replays multiple overdue timers oldest-first, not by list order', () {
      final now = DateTime(2026, 1, 2);
      final newer = timerAt('newer', now.subtract(const Duration(hours: 1)));
      final older = timerAt('older', now.subtract(const Duration(hours: 5)));
      final future = timerAt('future', now.add(const Duration(hours: 1)));
      final timers = [newer, future, older];

      final due = EnemyAttackSchedulingService.nextDueTimer(timers, now);
      expect(due?.id, 'older');
    });
  });
}
