import 'package:collection/collection.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_skill.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

// Why a skill can't be unlocked right now — see the vault's Skill System
// Overview for the mechanic this checks against.
enum SkillUnlockBlockReason {
  alreadyOwned,
  tierLocked,
  insufficientPoints,
}

// Why a skill can't be upgraded right now.
enum SkillUpgradeBlockReason {
  notOwned,
  insufficientPoints,
}

class SkillUnlockResult {
  final bool wasUnlocked;
  final SkillUnlockBlockReason? blockReason;
  final CharacterSkill? characterSkill;

  const SkillUnlockResult({
    required this.wasUnlocked,
    this.blockReason,
    this.characterSkill,
  });
}

class SkillUpgradeResult {
  final bool wasUpgraded;
  final SkillUpgradeBlockReason? blockReason;
  final CharacterSkill? characterSkill;

  const SkillUpgradeResult({
    required this.wasUpgraded,
    this.blockReason,
    this.characterSkill,
  });
}

// Spends Skill Points (earned via LevelingService) to unlock a new skill or
// upgrade an owned one — see the Skills UI ticket, subtask 2. Same "pure
// static logic + DB-touching instance wrapper" split used throughout this
// codebase (CombatService, StatusEffectService, ...): checkUnlock/
// checkUpgrade/requiredLevelForTier are unit-testable without a database,
// while unlockSkill/upgradeSkill do the actual persisting.
//
// Deliberately tier-agnostic: nothing here hardcodes Mage or Tier 1. The
// only reason Tiers 2-5 stay unreachable today is that skills.json has no
// data for them yet — the moment it does, this service already understands
// them via SkillData.tier and requiredLevelForTier.
class SkillProgressionService {
  final Database db;
  final GameData gameData;
  late CharacterRepository characterRepository;

  SkillProgressionService({required this.db, required this.gameData}) {
    characterRepository = CharacterRepository(db: db);
  }

  // Tier N unlocks at character level (N-1)*20 — Tier 1 is the one
  // exception, available from level 1 rather than level 0 (see the vault's
  // Skill System Overview: "Tier 1 at level 1, Tier 2 at level 20, Tier 3
  // at level 40, ...").
  static int requiredLevelForTier(int tier) =>
      tier <= 1 ? 1 : (tier - 1) * 20;

  // Pure — no DB access. Returns null when the unlock is allowed.
  static SkillUnlockBlockReason? checkUnlock({
    required SkillData skill,
    required int characterLevel,
    required int skillPoints,
    required bool alreadyOwned,
  }) {
    if (alreadyOwned) return SkillUnlockBlockReason.alreadyOwned;
    if (characterLevel < requiredLevelForTier(skill.tier)) {
      return SkillUnlockBlockReason.tierLocked;
    }
    if (skillPoints <= 0) return SkillUnlockBlockReason.insufficientPoints;
    return null;
  }

  // Pure — no DB access. Returns null when the upgrade is allowed. No
  // upper bound on the resulting level is enforced — the number of levels
  // per skill isn't decided yet (see the vault's Skill System Overview),
  // so upgrades stay uncapped this pass.
  static SkillUpgradeBlockReason? checkUpgrade({
    required bool owned,
    required int skillPoints,
  }) {
    if (!owned) return SkillUpgradeBlockReason.notOwned;
    if (skillPoints <= 0) return SkillUpgradeBlockReason.insufficientPoints;
    return null;
  }

  Future<SkillUnlockResult> unlockSkill({
    required Character character,
    required String skillId,
  }) async {
    final skillData = gameData.getSkillDataById(skillId);
    final alreadyOwned =
        character.skills.any((owned) => owned.skillId == skillId);
    final blockReason = checkUnlock(
      skill: skillData,
      characterLevel: character.level,
      skillPoints: character.skillPoints,
      alreadyOwned: alreadyOwned,
    );
    if (blockReason != null) {
      return SkillUnlockResult(wasUnlocked: false, blockReason: blockReason);
    }

    final characterSkill = CharacterSkill(
      id: const Uuid().v4(),
      characterId: character.id,
      skillId: skillId,
      level: 1,
    );
    await characterRepository.insertCharacterSkill(characterSkill);
    await characterRepository.updateCharacter(
      character.copyWith(skillPoints: character.skillPoints - 1),
    );
    return SkillUnlockResult(
        wasUnlocked: true, characterSkill: characterSkill);
  }

  Future<SkillUpgradeResult> upgradeSkill({
    required Character character,
    required String skillId,
  }) async {
    final owned = character.skills
        .firstWhereOrNull((skill) => skill.skillId == skillId);
    final blockReason = checkUpgrade(
      owned: owned != null,
      skillPoints: character.skillPoints,
    );
    if (blockReason != null) {
      return SkillUpgradeResult(wasUpgraded: false, blockReason: blockReason);
    }

    final updated = owned!.copyWith(level: owned.level + 1);
    await characterRepository.updateCharacterSkill(updated);
    await characterRepository.updateCharacter(
      character.copyWith(skillPoints: character.skillPoints - 1),
    );
    return SkillUpgradeResult(wasUpgraded: true, characterSkill: updated);
  }
}
