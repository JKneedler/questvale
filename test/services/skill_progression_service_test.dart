import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/services/skill_progression_service.dart';

SkillData _skill({int tier = 1}) {
  return SkillData(
    id: 'test-skill',
    characterClass: CharacterClass.mage,
    tier: tier,
    name: 'Test Skill',
    description: '',
    iconPath: '',
    type: SkillType.active,
    buttonColor: SkillButtonColor.fireRed,
  );
}

void main() {
  group('SkillProgressionService.requiredLevelForTier', () {
    test('Tier 1 is available from level 1, not level 0', () {
      expect(SkillProgressionService.requiredLevelForTier(1), 1);
    });

    test('Tiers 2-5 unlock every 20 levels', () {
      expect(SkillProgressionService.requiredLevelForTier(2), 20);
      expect(SkillProgressionService.requiredLevelForTier(3), 40);
      expect(SkillProgressionService.requiredLevelForTier(4), 60);
      expect(SkillProgressionService.requiredLevelForTier(5), 80);
    });
  });

  group('SkillProgressionService.checkUnlock', () {
    test('allowed (null) when the tier is reached, points are available, and not already owned',
        () {
      final reason = SkillProgressionService.checkUnlock(
        skill: _skill(tier: 1),
        characterLevel: 1,
        skillPoints: 1,
        alreadyOwned: false,
      );
      expect(reason, isNull);
    });

    test('blocked as alreadyOwned even with points and level to spare', () {
      final reason = SkillProgressionService.checkUnlock(
        skill: _skill(tier: 1),
        characterLevel: 50,
        skillPoints: 5,
        alreadyOwned: true,
      );
      expect(reason, SkillUnlockBlockReason.alreadyOwned);
    });

    test('blocked as tierLocked below the tier\'s required level', () {
      final reason = SkillProgressionService.checkUnlock(
        skill: _skill(tier: 2),
        characterLevel: 19,
        skillPoints: 5,
        alreadyOwned: false,
      );
      expect(reason, SkillUnlockBlockReason.tierLocked);
    });

    test('not tierLocked exactly at the tier\'s required level', () {
      final reason = SkillProgressionService.checkUnlock(
        skill: _skill(tier: 2),
        characterLevel: 20,
        skillPoints: 1,
        alreadyOwned: false,
      );
      expect(reason, isNull);
    });

    test('blocked as insufficientPoints with 0 points, even when the tier is unlocked', () {
      final reason = SkillProgressionService.checkUnlock(
        skill: _skill(tier: 1),
        characterLevel: 10,
        skillPoints: 0,
        alreadyOwned: false,
      );
      expect(reason, SkillUnlockBlockReason.insufficientPoints);
    });

    test('alreadyOwned takes priority over tierLocked when both apply', () {
      final reason = SkillProgressionService.checkUnlock(
        skill: _skill(tier: 5),
        characterLevel: 1,
        skillPoints: 5,
        alreadyOwned: true,
      );
      expect(reason, SkillUnlockBlockReason.alreadyOwned);
    });
  });

  group('SkillProgressionService.checkUpgrade', () {
    test('allowed (null) when owned and points are available', () {
      final reason =
          SkillProgressionService.checkUpgrade(owned: true, skillPoints: 1);
      expect(reason, isNull);
    });

    test('blocked as notOwned regardless of points', () {
      final reason =
          SkillProgressionService.checkUpgrade(owned: false, skillPoints: 5);
      expect(reason, SkillUpgradeBlockReason.notOwned);
    });

    test('blocked as insufficientPoints with 0 points, even when owned', () {
      final reason =
          SkillProgressionService.checkUpgrade(owned: true, skillPoints: 0);
      expect(reason, SkillUpgradeBlockReason.insufficientPoints);
    });

    test('notOwned takes priority over insufficientPoints when both apply', () {
      final reason =
          SkillProgressionService.checkUpgrade(owned: false, skillPoints: 0);
      expect(reason, SkillUpgradeBlockReason.notOwned);
    });
  });
}
