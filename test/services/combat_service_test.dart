import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/data/models/stat_modifier.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/services/combat_service.dart';

Enemy _enemy({String id = 'enemy-1', int currentHealth = 20}) => Enemy(
      id: id,
      enemyDataId: 'field_rat',
      encounterId: 'encounter-1',
      currentHealth: currentHealth,
      position: 0,
    );

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

  group('computeRawDamage', () {
    test('multiplies the skill\'s damageMultiplier by the resolved attack power', () {
      final stats = _statsWithAttackPowerTier(1); // baseAttackPower = 4
      final damageData = DamageData(
          damageMultiplier: 1.5, damageType: SkillDamageType.physical);
      expect(CombatService.computeRawDamage(damageData, stats), 6); // 1.5 * 4
    });

    test('selects attack power via the damage data\'s declared damage type', () {
      final stats = _statsWithAttackPowerTier(2); // baseAttackPower = 8
      final physical = CombatService.computeRawDamage(
          DamageData(damageMultiplier: 1.0, damageType: SkillDamageType.physical),
          stats);
      final fire = CombatService.computeRawDamage(
          DamageData(damageMultiplier: 1.0, damageType: SkillDamageType.fire),
          stats);
      // No elemental multiplier was rolled on this gear, so fire reads the
      // same base as physical here — attackPowerFor's own test file covers
      // the case where they actually diverge.
      expect(physical, 8);
      expect(fire, 8);
    });

    test('an ungeared character (0 attack power) deals 0 damage — no fallback minimum', () {
      final stats = PlayerCombatStats(playerLevel: 1, equipments: const []);
      final damageData = DamageData(
          damageMultiplier: 3.0, damageType: SkillDamageType.physical);
      expect(CombatService.computeRawDamage(damageData, stats), 0);
    });

    test('rounds rather than truncates', () {
      final stats = _statsWithAttackPowerTier(1); // baseAttackPower = 4
      // 1.375 * 4 = 5.5 -> rounds to 6, not truncated to 5.
      final damageData = DamageData(
          damageMultiplier: 1.375, damageType: SkillDamageType.physical);
      expect(CombatService.computeRawDamage(damageData, stats), 6);
    });
  });

  group('resolveDamageAgainstEnemy', () {
    // Shared by applyDamage (skill hits) and StatusEffectService's Burn
    // tick resolution — see its own doc comment on why StatusEffectService
    // can't just call applyDamage/hold a CombatService.
    test('a hit under current health does not kill', () {
      final resolved =
          CombatService.resolveDamageAgainstEnemy(5, _enemy(currentHealth: 20));
      expect(resolved.result.damageDone, 5);
      expect(resolved.result.didKill, isFalse);
      expect(resolved.updatedEnemy.currentHealth, 15);
    });

    test('a hit exactly at current health kills and reports the full amount', () {
      final resolved =
          CombatService.resolveDamageAgainstEnemy(20, _enemy(currentHealth: 20));
      expect(resolved.result.damageDone, 20);
      expect(resolved.result.didKill, isTrue);
      expect(resolved.updatedEnemy.currentHealth, 0);
    });

    test('overkill reports only the health that was actually there, not the raw damage', () {
      final resolved =
          CombatService.resolveDamageAgainstEnemy(999, _enemy(currentHealth: 20));
      expect(resolved.result.damageDone, 20);
      expect(resolved.result.didKill, isTrue);
      expect(resolved.updatedEnemy.currentHealth, 0);
    });
  });
}

PlayerCombatStats _statsWithAttackPowerTier(int tier,
    {DamageType weaponDamageType = DamageType.physical}) {
  final equipment = Equipment(
    id: 'weapon-1',
    characterId: 'character-1',
    rarity: Rarity.common,
    type: EquipmentType.wandAndFocus,
    tier: tier,
    attackPower: 0,
    damageType: weaponDamageType,
    armorValue: 0,
    statModifiers: [
      StatModifier(
        id: 'mod-1',
        location: StatModifierLocation.equipment,
        equipmentId: 'weapon-1',
        type: StatModifierType.attackPower,
        tier: tier,
      ),
    ],
  );
  return PlayerCombatStats(playerLevel: 1, equipments: [equipment]);
}
