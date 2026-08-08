import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/services/mote_service.dart';

// Marker base for whatever a class resource reports back from a single
// skill cast — deliberately empty. Each class resource's actual result
// shape stays its own type rather than being forced into a common one:
// MoteInteractionResult's fields (motesConsumed/moteGenerated/moteFizzled)
// don't generalize to a flat scalar pool like Warrior's future Rage or
// Rogue's future Focus, mirroring the vault's App Structure note's ruling
// against a shared ClassResource *table* — this is the same call, one
// level up, for the *result* type. Callers that care about a specific
// resource cast to that type (see SkillCastContext.moteResult); callers
// that don't (the common case for non-Mage skills) can ignore it entirely.
abstract class ClassResourceResult {}

class NoopClassResourceResult implements ClassResourceResult {
  const NoopClassResourceResult();
}

class MoteClassResourceResult implements ClassResourceResult {
  final MoteInteractionResult moteResult;
  const MoteClassResourceResult(this.moteResult);
}

// One resolver implementation per class, so CombatService.castSkill doesn't
// need to switch on characterClass itself to know which resource system to
// touch — see the vault's Skill System Architecture note. Warrior and Rogue
// don't have a resource yet, so they fall back to NoopClassResourceResolver
// rather than throwing; that's the seam Rage/Focus slot into later without
// touching castSkill or any skill's execute().
abstract class ClassResourceResolver {
  Future<ClassResourceResult> resolve(SkillData skillData, String characterId);

  static ClassResourceResolver forCharacterClass(
      CharacterClass characterClass, CharacterRepository characterRepository) {
    switch (characterClass) {
      case CharacterClass.mage:
        return MageMoteResolver(
            moteService: MoteService(characterRepository: characterRepository));
      case CharacterClass.warrior:
      case CharacterClass.rogue:
        return const NoopClassResourceResolver();
    }
  }
}

class NoopClassResourceResolver implements ClassResourceResolver {
  const NoopClassResourceResolver();

  @override
  Future<ClassResourceResult> resolve(
      SkillData skillData, String characterId) async {
    return const NoopClassResourceResult();
  }
}

// Thin adapter over the existing MoteService — behavior is unchanged from
// before this ticket, just reached through the generic interface instead of
// CombatCubit calling MoteService directly.
class MageMoteResolver implements ClassResourceResolver {
  final MoteService moteService;

  MageMoteResolver({required this.moteService});

  @override
  Future<ClassResourceResult> resolve(
      SkillData skillData, String characterId) async {
    final result = await moteService.resolve(skillData, characterId);
    return MoteClassResourceResult(result);
  }
}
