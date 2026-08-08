import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/services/class_resource_resolver.dart';

SkillData _skill() {
  return SkillData(
    id: 'test-skill',
    characterClass: CharacterClass.warrior,
    tier: 1,
    name: 'Test Skill',
    description: '',
    iconPath: '',
    type: SkillType.active,
    buttonColor: SkillButtonColor.fireRed,
  );
}

void main() {
  group('NoopClassResourceResolver', () {
    // Warrior/Rogue don't have a resource yet — this is the seam
    // Rage/Focus slot into later without touching CombatService.castSkill
    // or any skill's execute(). Pure/no DB, unlike MageMoteResolver which
    // wraps MoteService's DB-touching resolve().
    test('always resolves to NoopClassResourceResult, regardless of skill', () async {
      const resolver = NoopClassResourceResolver();
      final result = await resolver.resolve(_skill(), 'character-1');
      expect(result, isA<NoopClassResourceResult>());
    });
  });
}
