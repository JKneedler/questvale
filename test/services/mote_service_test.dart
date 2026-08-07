import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/models/mage_motes.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/services/mote_service.dart';

const characterId = 'character-1';

SkillData _skill({
  MoteInteractionType moteInteraction = MoteInteractionType.none,
  MoteElement? moteElement,
}) {
  return SkillData(
    id: 'test-skill',
    characterClass: CharacterClass.mage,
    tier: 1,
    name: 'Test Skill',
    description: '',
    iconPath: '',
    type: SkillType.active,
    buttonColor: SkillButtonColor.fireRed,
    moteInteraction: moteInteraction,
    moteElement: moteElement,
  );
}

void main() {
  group('applyInteraction — none', () {
    test('touches nothing, regardless of moteElement being set', () {
      const motes = MageMotes(characterId: characterId, fireMotes: 1);
      final result = MoteService.applyInteraction(
          motes, _skill(moteElement: MoteElement.fire));
      expect(result.motes, isNull);
      expect(result.motesConsumed, 0);
      expect(result.moteGenerated, isFalse);
    });

    test('is a no-op even if moteInteraction is generate/consume but no element is set',
        () {
      const motes = MageMotes(characterId: characterId);
      final result = MoteService.applyInteraction(
          motes, _skill(moteInteraction: MoteInteractionType.generate));
      expect(result.motes, isNull);
    });
  });

  group('applyInteraction — generate', () {
    test('banks 1 mote of the declared element', () {
      const motes = MageMotes(characterId: characterId);
      final result = MoteService.applyInteraction(
          motes,
          _skill(
              moteInteraction: MoteInteractionType.generate,
              moteElement: MoteElement.fire));
      expect(result.motes?.fireMotes, 1);
      expect(result.moteGenerated, isTrue);
      expect(result.moteFizzled, isFalse);
    });

    test('fizzles silently at the shared cap', () {
      const motes = MageMotes(characterId: characterId, fireMotes: 3);
      final result = MoteService.applyInteraction(
          motes,
          _skill(
              moteInteraction: MoteInteractionType.generate,
              moteElement: MoteElement.ice));
      expect(result.moteGenerated, isFalse);
      expect(result.moteFizzled, isTrue);
      expect(result.motes?.iceMotes, 0);
    });
  });

  group('applyInteraction — consume', () {
    test('reports the consumed count for the skill to scale its effect', () {
      const motes = MageMotes(characterId: characterId, iceMotes: 3);
      final result = MoteService.applyInteraction(
          motes,
          _skill(
              moteInteraction: MoteInteractionType.consume,
              moteElement: MoteElement.ice));
      expect(result.motesConsumed, 3);
      expect(result.motes?.iceMotes, 0);
    });

    test('consuming an empty element reports 0 consumed, not an error', () {
      const motes = MageMotes(characterId: characterId);
      final result = MoteService.applyInteraction(
          motes,
          _skill(
              moteInteraction: MoteInteractionType.consume,
              moteElement: MoteElement.fire));
      expect(result.motesConsumed, 0);
    });
  });
}
