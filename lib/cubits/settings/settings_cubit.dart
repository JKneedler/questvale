import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/settings/settings_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_skill.dart';
import 'package:questvale/data/models/character_stats.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/mage_motes.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/services/equipment_service.dart';
import 'package:questvale/services/leveling_service.dart';
import 'package:questvale/services/skill_progression_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final Database db;
  final GameData gameData;
  final PlayerCubit playerCubit;
  final ThemeCubit themeCubit;
  late EquipmentRepository equipmentRepository;
  late CharacterRepository characterRepository;
  late QuestRepository questRepository;
  late EncounterRepository encounterRepository;
  late TodoRepository todoRepository;

  SettingsCubit(
      {required this.db,
      required this.gameData,
      required this.playerCubit,
      required this.themeCubit,
      required Character character})
      : super(SettingsState(character: character)) {
    equipmentRepository = EquipmentRepository(db: db);
    characterRepository = CharacterRepository(db: db);
    questRepository = QuestRepository(db: db);
    encounterRepository = EncounterRepository(db: db);
    todoRepository = TodoRepository(db: db);
  }

  void setTheme(String themeId) => themeCubit.setTheme(themeId);

  // Every admin action below finishes with playerCubit.loadCharacter() —
  // PlayerCubit holds the canonical Character used elsewhere (world_tab,
  // todo_tab's AP display, etc.) and won't pick up any of these mutations
  // until reloaded, regardless of whether the action touched the Character
  // row itself.
  Future<void> generateLoot() async {
    final equipmentService = EquipmentService(db: db);
    final questZones = gameData.questZones;
    for (var i = 0; i < 10; i++) {
      final equipment = equipmentService.generateRandomTestEquipment(
          state.character, questZones[0], EncounterType.genericCombat);
      await equipmentRepository.insertEquipment(equipment);
    }
    await playerCubit.loadCharacter();
  }

  Future<void> resetAp() async {
    final updated = await characterRepository.updateCharacter(
      state.character.copyWith(actionPoints: 0, dailyApEarned: 0),
    );
    emit(state.copyWith(character: updated));
    await playerCubit.loadCharacter();
  }

  // Grants exactly enough exp to cross the next level threshold — a
  // minimal call site for LevelingService (see the Skills UI ticket's
  // subtask 1) so a level-up (and its Skill Point) can be triggered on
  // demand instead of needing a real encounter reward.
  Future<void> levelUp() async {
    final character = state.character;
    final expNeeded =
        LevelingService.expForLevel(character.level) - character.currentExp;
    final levelUpResult = LevelingService.applyExp(
      level: character.level,
      currentExp: character.currentExp,
      expGained: expNeeded,
    );
    final updated = await characterRepository.updateCharacter(
      character.copyWith(
        level: levelUpResult.level,
        currentExp: levelUpResult.currentExp,
        skillPoints: character.skillPoints + levelUpResult.skillPointsGained,
      ),
    );
    emit(state.copyWith(character: updated));
    await playerCubit.loadCharacter();
  }

  // Minimal call site for SkillProgressionService — see the Skills UI
  // ticket's subtask 2, which is deliberately UI-less (the real Skills
  // Gear-Up screen is subtask 3). Picks the first not-yet-owned skill in
  // game-data declaration order, a no-op if every skill is already owned
  // or the next one is tier-locked/unaffordable.
  Future<void> unlockNextSkill() async {
    final skillProgressionService =
        SkillProgressionService(db: db, gameData: gameData);
    final character = state.character;
    final nextSkill = gameData.skills.firstWhereOrNull(
        (skill) => !character.skills.any((owned) => owned.skillId == skill.id));
    if (nextSkill == null) return;
    await skillProgressionService.unlockSkill(
        character: character, skillId: nextSkill.id);
    final updated = await characterRepository.getCharacterById(character.id);
    emit(state.copyWith(character: updated));
    await playerCubit.loadCharacter();
  }

  // Same minimal-call-site reasoning as unlockNextSkill — upgrades
  // whichever owned skill happens to be first, a no-op if the character
  // owns nothing yet or has no Skill Points left.
  Future<void> upgradeFirstSkill() async {
    final skillProgressionService =
        SkillProgressionService(db: db, gameData: gameData);
    final character = state.character;
    if (character.skills.isEmpty) return;
    await skillProgressionService.upgradeSkill(
        character: character, skillId: character.skills.first.skillId);
    final updated = await characterRepository.getCharacterById(character.id);
    emit(state.copyWith(character: updated));
    await playerCubit.loadCharacter();
  }

  Future<void> deleteAllTags() async {
    await characterRepository.deleteAllTags(state.character.id);
    await playerCubit.loadCharacter();
  }

  Future<void> deleteAllTodos() async {
    await todoRepository.deleteAllTodosForCharacter(state.character.id);
    await playerCubit.loadCharacter();
  }

  // Re-equips a fresh starter weapon after clearing everything — leaving
  // the character fully unequipped would mean 0 base attack power (and so
  // 0 damage) now that CombatService actually consults it, per the Skill
  // System Foundations ticket's damage seam.
  Future<void> deleteAllEquipment() async {
    final cleared =
        await characterRepository.updateCharacter(_unequipped(state.character));
    await equipmentRepository.deleteAllEquipmentForCharacter(cleared.id);
    final weapon = EquipmentService.generateStarterWeapon(cleared);
    await equipmentRepository.insertEquipment(weapon);
    final updated = await characterRepository.updateCharacter(
        cleared.copyWithEquippedForSlot(EquipmentSlot.weapon, weapon));
    emit(state.copyWith(character: updated));
    await playerCubit.loadCharacter();
  }

  // Uses getQuestsForCharacter (never throws on >1 row), not getQuest — a
  // debug recovery action can't depend on the very "at most one quest row"
  // invariant it might be the one called on to repair. Previously this
  // called getQuest first, which throws on a character with more than one
  // stray quest row, so the action couldn't self-recover from that state
  // and had to be fixed by hand in the DB. Loops over every quest row
  // found (0, 1, or many) and cleans each one's encounter/rewards before
  // deleting all of them.
  Future<void> cancelQuest() async {
    final quests =
        await questRepository.getQuestsForCharacter(state.character.id);
    for (final quest in quests) {
      final encounter =
          await encounterRepository.getEncounterByQuestId(quest.id);
      if (encounter != null) {
        await encounterRepository.enemyRepository
            .deleteEnemiesByEncounterId(encounter.id);
        await encounterRepository.deleteEncounter(encounter);
      }
      await encounterRepository.deleteEncounterRewardsByQuestId(quest.id);
    }
    await questRepository.deleteQuestsForCharacter(state.character.id);
    await playerCubit.loadCharacter();
  }

  Future<void> resetCharacter() async {
    final c = state.character;

    // Clear out any invested/leveled skills first, then recreate exactly
    // the loadout QuestvaleDB.initializeDB() seeds a brand-new character
    // with — just Arcane Bolt, the class's free basic attack. Every other
    // skill (Firebolt included) is unlocked with Skill Points via
    // SkillProgressionService, not seeded for free, so a reset character
    // ends up back at that same starting point rather than with a loadout
    // it hasn't earned.
    await characterRepository.deleteAllSkillsForCharacter(c.id);
    final activeSkillSlot1 = CharacterSkill(
      id: const Uuid().v4(),
      characterId: c.id,
      skillId: 'mage-1-arcane_bolt',
      level: 1,
    );
    await characterRepository.insertCharacterSkill(activeSkillSlot1);

    // No gear at this point (about to be wiped below anyway), so
    // PlayerCombatStats.maxHealth here is exactly
    // characterClass.baseMaxHealth + BASE_HEALTH_PER_LEVEL*level — routed
    // through the one canonical formula instead of hand-duplicating it, so
    // this can't drift out of sync with it again. Uses level 1 (not
    // c.level) since a reset character's level resets too, same as
    // QuestvaleDB.initializeDB()'s brand-new character.
    final resetMaxHealth = PlayerCombatStats(
      playerLevel: 1,
      characterClass: c.characterClass,
      equipments: const [],
    ).maxHealth;
    final reset = Character(
      id: c.id,
      name: c.name,
      characterClass: c.characterClass,
      level: 1,
      gold: 0,
      currentExp: 0,
      currentHealth: resetMaxHealth,
      actionPoints: 0,
      // equipped* omitted -> null (unequipped). skills defaults to const [].
      activeSkillSlot1: activeSkillSlot1,
      dailyApEarned: 0,
      themeId: c.themeId,
      // Invested skills were just wiped above, so any unspent points reset
      // to 0 too rather than carrying over — consistent with the rest of
      // this reset.
      skillPoints: 0,
    );
    final updated = await characterRepository.updateCharacter(reset);
    await equipmentRepository.deleteAllEquipmentForCharacter(updated.id);
    await characterRepository
        .updateCharacterStats(CharacterStats(characterId: updated.id));
    if (updated.characterClass == CharacterClass.mage) {
      await characterRepository
          .updateMageMotes(MageMotes(characterId: updated.id));
    }

    // Re-equip a starter weapon rather than leaving the reset character
    // fully unequipped — same reasoning as deleteAllEquipment above.
    final weapon = EquipmentService.generateStarterWeapon(updated);
    await equipmentRepository.insertEquipment(weapon);
    final equipped = await characterRepository.updateCharacter(
        updated.copyWithEquippedForSlot(EquipmentSlot.weapon, weapon));

    emit(state.copyWith(character: equipped));
    await playerCubit.loadCharacter();
  }

  // Character.copyWith can't null a field (its `?? this.field` pattern
  // treats an explicit null as "unchanged"), so unequipping requires
  // constructing a new Character directly, omitting every equipped* param
  // — same workaround used elsewhere in this codebase (e.g.
  // AddTodoCubit/EditTodoCubit's dueDateCleared()).
  Character _unequipped(Character c) {
    return Character(
      id: c.id,
      name: c.name,
      characterClass: c.characterClass,
      level: c.level,
      gold: c.gold,
      currentExp: c.currentExp,
      currentHealth: c.currentHealth,
      actionPoints: c.actionPoints,
      skills: c.skills,
      activeSkillSlot1: c.activeSkillSlot1,
      activeSkillSlot2: c.activeSkillSlot2,
      activeSkillSlot3: c.activeSkillSlot3,
      activeSkillSlot4: c.activeSkillSlot4,
      activeSkillSlot5: c.activeSkillSlot5,
      dailyApEarned: c.dailyApEarned,
      dailyApEarnedDate: c.dailyApEarnedDate,
      themeId: c.themeId,
      skillPoints: c.skillPoints,
    );
  }
}
