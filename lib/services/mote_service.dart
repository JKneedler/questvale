import 'package:questvale/data/models/mage_motes.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/data/repositories/character_repository.dart';

// Outcome of resolving a single skill cast against the caster's Mote bank.
// `none` (the default) covers every skill that doesn't touch motes at all —
// the overwhelmingly common case, including every non-Mage skill — so
// callers that don't care about motes can ignore this without a null check.
class MoteInteractionResult {
  final MageMotes? motes;
  final int motesConsumed;
  final bool moteGenerated;
  // True only when a generate-flagged skill fired while the bank was
  // already at MOTE_CAP — the mote fizzled rather than banking.
  final bool moteFizzled;

  const MoteInteractionResult({
    this.motes,
    this.motesConsumed = 0,
    this.moteGenerated = false,
    this.moteFizzled = false,
  });

  static const none = MoteInteractionResult();
}

// The combat resolver for skill <-> Mote bank interaction (subtask 2 of the
// Mage Mote System ticket). Reads a skill's declared moteInteraction/
// moteElement (see SkillData) and applies it to the caster's MageMotes.
// Deliberately skill-effect-agnostic: this only moves motes in and out of
// the bank and reports how many were consumed — turning that count into
// damage/shield scaling is each skill's own job (BaseActiveSkill.execute),
// same as it already owns turning AP cost into whatever else it does.
// Consuming motes rides on the skill's own existing AP cost/cooldown; no
// separate resource-spend mechanic exists.
//
// Pure computation lives in the static applyInteraction below so it's unit
// testable without a live Database, same split as
// EnemyAttackSchedulingService (selectMove/recomputeSegment static, DB
// orchestration on the instance).
class MoteService {
  final CharacterRepository characterRepository;

  MoteService({required this.characterRepository});

  // Given the caster's current motes and the skill being cast, returns what
  // should happen — no I/O. `motes` is only non-null on the result when the
  // interaction actually touched the bank (i.e. not `none`), so callers can
  // tell "nothing to persist" apart from "persist this new state" without
  // re-deriving moteInteraction themselves.
  static MoteInteractionResult applyInteraction(
      MageMotes motes, SkillData skillData) {
    final element = skillData.moteElement;
    if (skillData.moteInteraction == MoteInteractionType.none ||
        element == null) {
      return MoteInteractionResult.none;
    }

    switch (skillData.moteInteraction) {
      case MoteInteractionType.none:
        return MoteInteractionResult.none;

      case MoteInteractionType.generate:
        final generated = motes.generate(element);
        // MageMotes.generate returns the same instance, unchanged, when the
        // cap is already full — identity is a reliable, cheap fizzle check.
        final fizzled = identical(generated, motes);
        return MoteInteractionResult(
          motes: generated,
          moteGenerated: !fizzled,
          moteFizzled: fizzled,
        );

      case MoteInteractionType.consume:
        final result = motes.consumeAll(element);
        return MoteInteractionResult(
          motes: result.motes,
          motesConsumed: result.consumed,
        );
    }
  }

  Future<MoteInteractionResult> resolve(
      SkillData skillData, String characterId) async {
    if (skillData.moteInteraction == MoteInteractionType.none ||
        skillData.moteElement == null) {
      return MoteInteractionResult.none;
    }
    final motes = await characterRepository.getMageMotes(characterId);
    final result = applyInteraction(motes, skillData);
    if (result.motes != null) {
      await characterRepository.updateMageMotes(result.motes!);
    }
    return result;
  }
}
