import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/services/leveling_service.dart';

void main() {
  group('LevelingService.expForLevel', () {
    test('is the placeholder level * 100 curve', () {
      expect(LevelingService.expForLevel(1), 100);
      expect(LevelingService.expForLevel(10), 1000);
    });
  });

  group('LevelingService.applyExp', () {
    test('a gain under the threshold just accumulates, no level-up', () {
      final result = LevelingService.applyExp(
        level: 5,
        currentExp: 200,
        expGained: 50,
      );
      expect(result.level, 5);
      expect(result.currentExp, 250);
      expect(result.skillPointsGained, 0);
      expect(result.leveledUp, isFalse);
    });

    test('a gain landing exactly on the threshold levels up with 0 leftover', () {
      final result = LevelingService.applyExp(
        level: 5,
        currentExp: 400,
        expGained: 100,
      );
      expect(result.level, 6);
      expect(result.currentExp, 0);
      expect(result.skillPointsGained, 1);
    });

    test('a gain crossing the threshold levels up and carries the remainder', () {
      final result = LevelingService.applyExp(
        level: 5,
        currentExp: 480,
        expGained: 50,
      );
      // 480 + 50 = 530, threshold for level 5 is 500 -> level 6 with 30 left
      expect(result.level, 6);
      expect(result.currentExp, 30);
      expect(result.skillPointsGained, 1);
    });

    test('a large gain can cross multiple level thresholds in one call', () {
      final result = LevelingService.applyExp(
        level: 1,
        currentExp: 0,
        expGained: 350,
      );
      // Lv1->2 costs 100 (250 left), Lv2->3 costs 200 (50 left), Lv3->4 costs
      // 300 (not enough) -> lands at level 3 with 50 exp and 2 points.
      expect(result.level, 3);
      expect(result.currentExp, 50);
      expect(result.skillPointsGained, 2);
    });

    test('zero exp gained changes nothing', () {
      final result = LevelingService.applyExp(
        level: 7,
        currentExp: 300,
        expGained: 0,
      );
      expect(result.level, 7);
      expect(result.currentExp, 300);
      expect(result.skillPointsGained, 0);
    });

    test('grants exactly 1 skill point per level gained', () {
      final result = LevelingService.applyExp(
        level: 1,
        currentExp: 0,
        expGained: 100,
      );
      expect(result.skillPointsGained, 1);
    });
  });
}
