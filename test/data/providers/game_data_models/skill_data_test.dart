import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/models/stat_modifier.dart';
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

  group('SkillEffectComponent.fromJson', () {
    test('parses a damage component (Firebolt-shaped)', () {
      final effect = SkillEffectComponent.fromJson({
        'kind': 0,
        'baseValue': 1.5,
        'valueScaler': 0.375,
        'damageType': 2,
      });
      expect(effect.kind, SkillEffectKind.damage);
      expect(effect.baseValue, 1.5);
      expect(effect.valueScaler, 0.375);
      expect(effect.damageType, SkillDamageType.fire);
      expect(effect.statusEffectType, isNull);
      expect(effect.statModifierType, isNull);
    });

    test('parses a statusEffectChance component (Frost Shard-shaped)', () {
      final effect = SkillEffectComponent.fromJson({
        'kind': 2,
        'baseValue': 0.2,
        'statusEffectType': 1,
      });
      expect(effect.kind, SkillEffectKind.statusEffectChance);
      expect(effect.statusEffectType, StatusEffectType.slow);
      expect(effect.damageType, isNull);
    });

    test('parses a statModifier component with a null statModifierType (Ice Ward-shaped)', () {
      final effect = SkillEffectComponent.fromJson({
        'kind': 3,
        'baseValue': 0.05,
        'valueScaler': 0.0375,
      });
      expect(effect.kind, SkillEffectKind.statModifier);
      expect(effect.baseValue, 0.05);
      expect(effect.statModifierType, isNull);
    });

    test('parses a statModifier component with a real statModifierType (Elemental Affinity-shaped)', () {
      final effect = SkillEffectComponent.fromJson({
        'kind': 3,
        'baseValue': 0.05,
        'statModifierType': 2,
      });
      expect(effect.statModifierType, StatModifierType.fireDamage);
    });

    test('parses a shield component with no damage/status/statModifier fields (Frost Armor-shaped)', () {
      final effect = SkillEffectComponent.fromJson({
        'kind': 1,
        'baseValue': 0.15,
        'valueScaler': 0.0625,
      });
      expect(effect.kind, SkillEffectKind.shield);
      expect(effect.damageType, isNull);
    });
  });

  group('SkillData.effects and convenience getters', () {
    test('defaults to an empty list when the key is absent', () {
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
      expect(skill.effects, isEmpty);
      expect(skill.damageEffect, isNull);
      expect(skill.shieldEffect, isNull);
      expect(skill.statusEffectChances, isEmpty);
      expect(skill.statModifierEffects, isEmpty);
    });

    test('parses a mixed effects list and exposes each kind via its getter (Hoarfrost Burst-shaped)', () {
      final skill = SkillData.fromJson({
        'id': 'test',
        'class': 0,
        'tier': 1,
        'name': 'Test',
        'description': '',
        'iconPath': '',
        'type': 0,
        'buttonColor': 2,
        'effects': [
          {'kind': 0, 'baseValue': 0.7, 'valueScaler': 0.1, 'damageType': 3},
          {'kind': 1, 'baseValue': 0.1, 'valueScaler': 0.02},
        ],
      });
      expect(skill.effects, hasLength(2));
      expect(skill.damageEffect?.baseValue, 0.7);
      expect(skill.damageEffect?.damageType, SkillDamageType.ice);
      expect(skill.shieldEffect?.baseValue, 0.1);
    });

    test('statusEffectChances and statModifierEffects return every matching component', () {
      final skill = SkillData.fromJson({
        'id': 'test',
        'class': 0,
        'tier': 1,
        'name': 'Test',
        'description': '',
        'iconPath': '',
        'type': 1,
        'buttonColor': 3,
        'effects': [
          {'kind': 3, 'baseValue': 0.05, 'statModifierType': 2},
          {'kind': 3, 'baseValue': 0.05, 'statModifierType': 3},
          {'kind': 2, 'baseValue': 0.2, 'statusEffectType': 0},
        ],
      });
      expect(skill.statModifierEffects, hasLength(2));
      expect(
        skill.statModifierEffects.map((e) => e.statModifierType),
        [StatModifierType.fireDamage, StatModifierType.iceDamage],
      );
      expect(skill.statusEffectChances, hasLength(1));
      expect(skill.statusEffectChances.single.statusEffectType, StatusEffectType.burn);
    });
  });
}
