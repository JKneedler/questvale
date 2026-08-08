import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/services/combat_service.dart';

Character _character({String id = 'character-1', int actionPoints = 5}) {
  return Character(
    id: id,
    name: 'Test',
    characterClass: CharacterClass.mage,
    level: 1,
    gold: 0,
    currentExp: 0,
    currentHealth: 10,
    actionPoints: actionPoints,
  );
}

SkillData _skill({
  String id = 'test-skill',
  double? cooldown,
  int? apCost,
}) {
  return SkillData(
    id: id,
    characterClass: CharacterClass.mage,
    tier: 1,
    name: 'Test Skill',
    description: '',
    iconPath: '',
    type: SkillType.active,
    buttonColor: SkillButtonColor.fireRed,
    cooldown: cooldown,
    apCost: apCost,
  );
}

void main() {
  group('cooldownOwnerId', () {
    test('combines character and skill id so each skill gets its own timer row', () {
      final id = CombatService.cooldownOwnerId('character-1', 'mage-1-firebolt');
      expect(id, 'character-1:mage-1-firebolt');
    });

    test('two different skills for the same character produce different ids', () {
      final a = CombatService.cooldownOwnerId('character-1', 'mage-1-firebolt');
      final b = CombatService.cooldownOwnerId('character-1', 'mage-1-frost_shard');
      expect(a, isNot(b));
    });
  });

  group('buildCooldownTimer', () {
    test('converts the skill\'s cooldown (hours) into remainingWork/nextTriggerAt', () {
      final now = DateTime(2026, 1, 1, 12);
      final timer = CombatService.buildCooldownTimer(
        character: _character(),
        skillData: _skill(id: 'mage-1-firebolt', cooldown: 0.5),
        encounterId: 'encounter-1',
        now: now,
        id: 'timer-1',
      );

      expect(timer.ownerId, 'character-1:mage-1-firebolt');
      expect(timer.kind, ScheduledTimerKind.skillCooldown);
      expect(timer.payload, 'mage-1-firebolt');
      expect(timer.currentRate, 1.0);
      expect(timer.recurring, isFalse);
      expect(timer.remainingWorkMs, (0.5 * Duration.millisecondsPerHour).round());
      expect(timer.nextTriggerAt,
          now.add(Duration(milliseconds: (0.5 * Duration.millisecondsPerHour).round())));
    });

    test('a null cooldown builds an already-elapsed (0ms) timer rather than throwing', () {
      final now = DateTime(2026, 1, 1);
      final timer = CombatService.buildCooldownTimer(
        character: _character(),
        skillData: _skill(id: 'mage-1-arcane_bolt', cooldown: null),
        encounterId: 'encounter-1',
        now: now,
        id: 'timer-1',
      );
      expect(timer.remainingWorkMs, 0);
      expect(timer.nextTriggerAt, now);
    });
  });

  group('isSkillReady', () {
    test('no timer at all means ready — nothing has ever armed a cooldown for it', () {
      expect(CombatService.isSkillReady(null, DateTime(2026, 1, 1)), isTrue);
    });

    test('not ready while now is before the timer\'s nextTriggerAt', () {
      final now = DateTime(2026, 1, 1, 12);
      final timer = ScheduledTimer(
        id: 't1',
        ownerId: 'character-1:mage-1-firebolt',
        encounterId: 'encounter-1',
        kind: ScheduledTimerKind.skillCooldown,
        payload: 'mage-1-firebolt',
        remainingWorkMs: 0,
        segmentStartedAt: now,
        nextTriggerAt: now.add(const Duration(minutes: 30)),
      );
      expect(CombatService.isSkillReady(timer, now), isFalse);
    });

    test('ready once now has reached the timer\'s nextTriggerAt', () {
      final now = DateTime(2026, 1, 1, 12);
      final timer = ScheduledTimer(
        id: 't1',
        ownerId: 'character-1:mage-1-firebolt',
        encounterId: 'encounter-1',
        kind: ScheduledTimerKind.skillCooldown,
        payload: 'mage-1-firebolt',
        remainingWorkMs: 0,
        segmentStartedAt: now.subtract(const Duration(minutes: 30)),
        nextTriggerAt: now,
      );
      expect(CombatService.isSkillReady(timer, now), isTrue);
    });
  });
}
