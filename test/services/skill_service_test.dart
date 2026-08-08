import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_skill.dart';
import 'package:questvale/data/models/stat_modifier.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/services/skill_service.dart';

Character _character({List<CharacterSkill> skills = const []}) {
  return Character(
    id: 'character-1',
    name: 'Test',
    characterClass: CharacterClass.mage,
    level: 1,
    gold: 0,
    currentExp: 0,
    currentHealth: 10,
    actionPoints: 0,
    skills: skills,
  );
}

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

  group('SkillService.findPassiveRegistryMismatches', () {
    test('empty when the declared set exactly matches the registry', () {
      final mismatch = SkillService.findPassiveRegistryMismatches(
          SkillService.registeredPassiveSkillIds);
      expect(mismatch.isEmpty, isTrue);
    });

    test('flags a skills.json passive id with no getPassiveSkillById case as missing',
        () {
      final declared = {
        ...SkillService.registeredPassiveSkillIds,
        'mage-2-arcane-mastery'
      };
      final mismatch = SkillService.findPassiveRegistryMismatches(declared);
      expect(mismatch.missingFromRegistry, {'mage-2-arcane-mastery'});
    });
  });

  group('SkillService.passiveModifiersFor', () {
    test('a character with no passive CharacterSkill rows contributes nothing',
        () async {
      final gameData = await GameData.load();
      final skillService = SkillService(gameData: gameData);
      expect(skillService.passiveModifiersFor(_character()), isEmpty);
    });

    test(
        'an active-skill CharacterSkill row (e.g. Firebolt) is filtered out, not treated as a passive',
        () async {
      final gameData = await GameData.load();
      final skillService = SkillService(gameData: gameData);
      final character = _character(skills: [
        const CharacterSkill(
            id: 'cs-1',
            characterId: 'character-1',
            skillId: 'mage-1-firebolt',
            level: 1),
      ]);
      expect(skillService.passiveModifiersFor(character), isEmpty);
    });

    test('Elemental Affinity contributes both fireDamage and iceDamage', () async {
      final gameData = await GameData.load();
      final skillService = SkillService(gameData: gameData);
      final character = _character(skills: [
        const CharacterSkill(
            id: 'cs-1',
            characterId: 'character-1',
            skillId: 'mage-1-elemental_affinity',
            level: 1),
      ]);
      final modifiers = skillService.passiveModifiersFor(character);
      expect(modifiers.map((m) => m.type),
          containsAll([StatModifierType.fireDamage, StatModifierType.iceDamage]));
      expect(modifiers.every((m) => m.location == StatModifierLocation.character),
          isTrue);
      expect(modifiers.every((m) => m.characterId == 'character-1'), isTrue);
    });

    test('Mote Potency and Ice Ward are constructible but stay inert', () async {
      final gameData = await GameData.load();
      final skillService = SkillService(gameData: gameData);
      final character = _character(skills: [
        const CharacterSkill(
            id: 'cs-1',
            characterId: 'character-1',
            skillId: 'mage-1-mote_potency',
            level: 1),
        const CharacterSkill(
            id: 'cs-2',
            characterId: 'character-1',
            skillId: 'mage-1-ice_ward',
            level: 1),
      ]);
      expect(skillService.passiveModifiersFor(character), isEmpty);
    });
  });
}
