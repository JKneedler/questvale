import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_skill.dart';
import 'package:questvale/helpers/shared_enums.dart';

Character _character({
  CharacterSkill? slot1,
  CharacterSkill? slot2,
  CharacterSkill? slot3,
}) {
  return Character(
    id: 'character-1',
    name: 'Test',
    characterClass: CharacterClass.mage,
    level: 1,
    gold: 0,
    currentExp: 0,
    currentHealth: 10,
    actionPoints: 0,
    activeSkillSlot1: slot1,
    activeSkillSlot2: slot2,
    activeSkillSlot3: slot3,
  );
}

CharacterSkill _skill(String skillId, {String id = 'cs-1'}) {
  return CharacterSkill(
      id: id, characterId: 'character-1', skillId: skillId, level: 1);
}

void main() {
  group('Character.activeSkillSlotAt', () {
    test('returns the skill in the requested 1-indexed slot', () {
      final firebolt = _skill('mage-1-firebolt');
      final character = _character(slot2: firebolt);
      expect(character.activeSkillSlotAt(2), firebolt);
    });

    test('returns null for an empty slot', () {
      final character = _character();
      expect(character.activeSkillSlotAt(1), isNull);
    });

    test('throws for an out-of-range slot number', () {
      final character = _character();
      expect(() => character.activeSkillSlotAt(0), throwsArgumentError);
      expect(() => character.activeSkillSlotAt(6), throwsArgumentError);
    });
  });

  group('Character.copyWithActiveSkillSlot', () {
    test('assigns into an empty slot, leaving other slots untouched', () {
      final arcaneBolt = _skill('mage-1-arcane_bolt', id: 'cs-1');
      final firebolt = _skill('mage-1-firebolt', id: 'cs-2');
      final character = _character(slot1: arcaneBolt);

      final updated = character.copyWithActiveSkillSlot(2, firebolt);

      expect(updated.activeSkillSlot1, arcaneBolt);
      expect(updated.activeSkillSlot2, firebolt);
    });

    test('replaces whatever was already in the target slot', () {
      final arcaneBolt = _skill('mage-1-arcane_bolt', id: 'cs-1');
      final firebolt = _skill('mage-1-firebolt', id: 'cs-2');
      final character = _character(slot1: arcaneBolt);

      final updated = character.copyWithActiveSkillSlot(1, firebolt);

      expect(updated.activeSkillSlot1, firebolt);
    });

    test('a skill already in a different slot is moved, not duplicated', () {
      final firebolt = _skill('mage-1-firebolt', id: 'cs-2');
      final character = _character(slot2: firebolt);

      final updated = character.copyWithActiveSkillSlot(1, firebolt);

      expect(updated.activeSkillSlot1, firebolt);
      expect(updated.activeSkillSlot2, isNull);
    });

    test('re-assigning a skill to the slot it is already in is a no-op move',
        () {
      final firebolt = _skill('mage-1-firebolt', id: 'cs-2');
      final character = _character(slot2: firebolt);

      final updated = character.copyWithActiveSkillSlot(2, firebolt);

      expect(updated.activeSkillSlot2, firebolt);
      expect(updated.activeSkillSlot1, isNull);
    });
  });

  group('Character.copyWithClearedActiveSkillSlot', () {
    test('unassigns the target slot, leaving other slots untouched', () {
      final arcaneBolt = _skill('mage-1-arcane_bolt', id: 'cs-1');
      final firebolt = _skill('mage-1-firebolt', id: 'cs-2');
      final character = _character(slot1: arcaneBolt, slot2: firebolt);

      final updated = character.copyWithClearedActiveSkillSlot(1);

      expect(updated.activeSkillSlot1, isNull);
      expect(updated.activeSkillSlot2, firebolt);
    });

    test('clearing an already-empty slot is a harmless no-op', () {
      final character = _character();
      final updated = character.copyWithClearedActiveSkillSlot(3);
      expect(updated.activeSkillSlot3, isNull);
    });
  });
}
