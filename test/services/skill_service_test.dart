import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/services/skill_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Regression test for the actual bug findRegistryMismatches was built to
  // catch: skills.json's `type` values were inverted relative to the
  // SkillType enum (active skills stored as passive and vice versa) until
  // this ticket, and nothing caught it because nothing read skill.type
  // before now. Constructing a real SkillService off the real asset —
  // rather than only the pure findRegistryMismatches cases below — is what
  // actually exercises SkillService's debug-mode assert end-to-end.
  test('constructing SkillService against the real skills.json does not throw',
      () async {
    final gameData = await GameData.load();
    expect(() => SkillService(gameData: gameData), returnsNormally);
  });

  group('SkillService.findRegistryMismatches', () {
    test('empty when the declared set exactly matches the registry', () {
      final mismatch = SkillService.findRegistryMismatches(
          SkillService.registeredActiveSkillIds);
      expect(mismatch.isEmpty, isTrue);
    });

    test('flags a skills.json id with no getSkillById case as missing', () {
      final declared = {...SkillService.registeredActiveSkillIds, 'mage-2-ice_spike'};
      final mismatch = SkillService.findRegistryMismatches(declared);
      expect(mismatch.isEmpty, isFalse);
      expect(mismatch.missingFromRegistry, {'mage-2-ice_spike'});
      expect(mismatch.staleInRegistry, isEmpty);
    });

    test('flags a registered id no longer declared in skills.json as stale', () {
      final declared = {...SkillService.registeredActiveSkillIds}
        ..remove('mage-1-frost_armor');
      final mismatch = SkillService.findRegistryMismatches(declared);
      expect(mismatch.isEmpty, isFalse);
      expect(mismatch.staleInRegistry, {'mage-1-frost_armor'});
      expect(mismatch.missingFromRegistry, isEmpty);
    });

    test('toString names the offending id(s) for both directions', () {
      final declared = {...SkillService.registeredActiveSkillIds, 'mage-2-ice_spike'}
        ..remove('mage-1-frost_armor');
      final mismatch = SkillService.findRegistryMismatches(declared);
      expect(mismatch.toString(), contains('mage-2-ice_spike'));
      expect(mismatch.toString(), contains('mage-1-frost_armor'));
    });
  });
}
