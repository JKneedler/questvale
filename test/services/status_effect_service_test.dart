import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/services/status_effect_service.dart';

void main() {
  group('timerOwnerId / targetIdFromTimerOwnerId', () {
    test('round-trips a target id through the composite owner id', () {
      final ownerId =
          StatusEffectService.timerOwnerId('enemy-1', StatusEffectType.burn);
      expect(ownerId, 'enemy-1:burn');
      expect(StatusEffectService.targetIdFromTimerOwnerId(ownerId), 'enemy-1');
    });

    test('burn and slow on the same target produce different owner ids', () {
      final burnOwnerId =
          StatusEffectService.timerOwnerId('enemy-1', StatusEffectType.burn);
      final slowOwnerId =
          StatusEffectService.timerOwnerId('enemy-1', StatusEffectType.slow);
      expect(burnOwnerId, isNot(slowOwnerId));
    });
  });

  group('mergeBurnApplication', () {
    test('a fresh application (no existing stacks) is just the full duration', () {
      final result = StatusEffectService.mergeBurnApplication(
        oldRemainingMs: 0,
        oldStacks: 0,
        applicationDurationMs: 21600000, // 6h
        newStacks: 1,
      );
      expect(result.remainingMs, 21600000);
      expect(result.stacks, 1);
    });

    test(
        'a small reapplication landing on a large existing stack barely moves the remaining duration',
        () {
      // 5 stacks with 1h left, topped up by 1 fresh 6h application.
      final result = StatusEffectService.mergeBurnApplication(
        oldRemainingMs: 3600000, // 1h
        oldStacks: 5,
        applicationDurationMs: 21600000, // 6h
        newStacks: 1,
      );
      // (3,600,000*5 + 21,600,000*1) / 6 = 6,600,000ms = 1h50m — barely
      // moved off the original 1h, matching the vault's "barely moves"
      // description; nowhere near a full 6h refresh.
      expect(result.remainingMs, 6600000);
      expect(result.stacks, 6);
    });

    test(
        'a fresh application on a single nearly-expired stack meaningfully refreshes it',
        () {
      final result = StatusEffectService.mergeBurnApplication(
        oldRemainingMs: 60000, // 1 minute left
        oldStacks: 1,
        applicationDurationMs: 21600000, // 6h
        newStacks: 1,
      );
      // (60,000*1 + 21,600,000*1) / 2 = 10,830,000ms ≈ 3h — a real refresh,
      // not just barely nudged.
      expect(result.remainingMs, 10830000);
      expect(result.stacks, 2);
    });

    test('stack count always accumulates additively regardless of duration math', () {
      final result = StatusEffectService.mergeBurnApplication(
        oldRemainingMs: 100,
        oldStacks: 2,
        applicationDurationMs: 100,
        newStacks: 3,
      );
      expect(result.stacks, 5);
    });
  });

  group('buildBurnTimer', () {
    test('a fresh 6h application ticks first at the tick interval, not the full duration', () {
      final now = DateTime(2026, 1, 1, 12);
      final timer = StatusEffectService.buildBurnTimer(
        targetId: 'enemy-1',
        encounterId: 'encounter-1',
        remainingMs: const Duration(hours: 6).inMilliseconds,
        now: now,
        id: 'timer-1',
      );
      expect(timer.ownerId, 'enemy-1:burn');
      expect(timer.kind, ScheduledTimerKind.statusEffectTick);
      expect(timer.payload, 'burn');
      expect(timer.recurring, isTrue);
      expect(timer.remainingWorkMs, const Duration(hours: 6).inMilliseconds);
      expect(timer.nextTriggerAt, now.add(const Duration(minutes: 30)));
    });

    test('a Burn with less than one tick interval left ticks exactly once more, at expiry', () {
      final now = DateTime(2026, 1, 1, 12);
      final timer = StatusEffectService.buildBurnTimer(
        targetId: 'enemy-1',
        encounterId: 'encounter-1',
        remainingMs: const Duration(minutes: 10).inMilliseconds,
        now: now,
        id: 'timer-1',
      );
      // min(30min tick interval, 10min remaining) — doesn't overshoot past
      // when the effect actually runs out.
      expect(timer.nextTriggerAt, now.add(const Duration(minutes: 10)));
    });
  });

  group('buildExpiryTimer', () {
    test('a one-shot, non-recurring timer scoped to the given duration', () {
      final now = DateTime(2026, 1, 1, 12);
      final timer = StatusEffectService.buildExpiryTimer(
        targetId: 'enemy-1',
        effectType: StatusEffectType.slow,
        encounterId: 'encounter-1',
        durationMs: const Duration(hours: 8).inMilliseconds,
        now: now,
        id: 'timer-1',
      );
      expect(timer.ownerId, 'enemy-1:slow');
      expect(timer.kind, ScheduledTimerKind.statusEffectExpiry);
      expect(timer.payload, 'slow');
      expect(timer.recurring, isFalse);
      expect(timer.nextTriggerAt, now.add(const Duration(hours: 8)));
    });

    test('also works for shield, keyed to its own owner id', () {
      final now = DateTime(2026, 1, 1, 12);
      final timer = StatusEffectService.buildExpiryTimer(
        targetId: 'character-1',
        effectType: StatusEffectType.shield,
        encounterId: 'encounter-1',
        durationMs: const Duration(hours: 12).inMilliseconds,
        now: now,
        id: 'timer-1',
      );
      expect(timer.ownerId, 'character-1:shield');
      expect(timer.payload, 'shield');
    });
  });

  group('resolveShieldAbsorption', () {
    test('a hit smaller than the shield is fully absorbed, nothing carries through', () {
      final result = StatusEffectService.resolveShieldAbsorption(20, 5);
      expect(result.absorbed, 5);
      expect(result.remainingShield, 15);
      expect(result.remainingDamage, 0);
    });

    test('a hit larger than the shield depletes it and the remainder carries through', () {
      final result = StatusEffectService.resolveShieldAbsorption(10, 15);
      expect(result.absorbed, 10);
      expect(result.remainingShield, 0);
      expect(result.remainingDamage, 5);
    });

    test('a hit exactly equal to the shield depletes it with nothing carrying through', () {
      final result = StatusEffectService.resolveShieldAbsorption(10, 10);
      expect(result.absorbed, 10);
      expect(result.remainingShield, 0);
      expect(result.remainingDamage, 0);
    });

    test('a zero shield lets all damage through untouched', () {
      final result = StatusEffectService.resolveShieldAbsorption(0, 8);
      expect(result.absorbed, 0);
      expect(result.remainingDamage, 8);
    });
  });
}
