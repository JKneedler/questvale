import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/helpers/shared_enums.dart';

void main() {
  group('SkillData.fromJson — mote interaction', () {
    test('defaults to none/null when the keys are absent (non-Mote skills)', () {
      final skill = SkillData.fromJson({
        'id': 'test',
        'class': 0,
        'tier': 1,
        'name': 'Test',
        'description': '',
        'iconPath': '',
        'type': 1,
        'buttonColor': 0,
      });
      expect(skill.moteInteraction, MoteInteractionType.none);
      expect(skill.moteElement, isNull);
    });

    test('parses a generate skill (Firebolt-shaped)', () {
      final skill = SkillData.fromJson({
        'id': 'test',
        'class': 0,
        'tier': 1,
        'name': 'Test',
        'description': '',
        'iconPath': '',
        'type': 1,
        'buttonColor': 1,
        'moteInteraction': 1,
        'moteElement': 0,
      });
      expect(skill.moteInteraction, MoteInteractionType.generate);
      expect(skill.moteElement, MoteElement.fire);
    });

    test('parses a consume skill (Hoarfrost Burst-shaped)', () {
      final skill = SkillData.fromJson({
        'id': 'test',
        'class': 0,
        'tier': 1,
        'name': 'Test',
        'description': '',
        'iconPath': '',
        'type': 1,
        'buttonColor': 2,
        'moteInteraction': 2,
        'moteElement': 1,
      });
      expect(skill.moteInteraction, MoteInteractionType.consume);
      expect(skill.moteElement, MoteElement.ice);
    });
  });

  test('cooldown parses fractional hours (Firebolt is 0.5h)', () {
    final skill = SkillData.fromJson({
      'id': 'test',
      'class': 0,
      'tier': 1,
      'name': 'Test',
      'description': '',
      'iconPath': '',
      'type': 1,
      'buttonColor': 1,
      'cooldown': 0.5,
    });
    expect(skill.cooldown, 0.5);
  });

  test('cooldown also accepts a whole-number JSON literal (0, not 0.0)', () {
    final skill = SkillData.fromJson({
      'id': 'test',
      'class': 0,
      'tier': 1,
      'name': 'Test',
      'description': '',
      'iconPath': '',
      'type': 1,
      'buttonColor': 0,
      'cooldown': 0,
    });
    expect(skill.cooldown, 0.0);
  });
}
