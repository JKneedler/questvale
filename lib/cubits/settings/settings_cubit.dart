import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/settings/settings_state.dart';
import 'package:questvale/cubits/theme/theme_cubit.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_stats.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:questvale/services/equipment_service.dart';
import 'package:sqflite/sqflite.dart';

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

  Future<void> deleteAllTags() async {
    await characterRepository.deleteAllTags(state.character.id);
    await playerCubit.loadCharacter();
  }

  Future<void> deleteAllTodos() async {
    await todoRepository.deleteAllTodosForCharacter(state.character.id);
    await playerCubit.loadCharacter();
  }

  Future<void> deleteAllEquipment() async {
    final updated = await characterRepository
        .updateCharacter(_unequipped(state.character));
    await equipmentRepository.deleteAllEquipmentForCharacter(updated.id);
    emit(state.copyWith(character: updated));
    await playerCubit.loadCharacter();
  }

  Future<void> cancelQuest() async {
    final quest = await questRepository.getQuest(state.character.id);
    if (quest == null) return;
    final encounter =
        await encounterRepository.getEncounterByQuestId(quest.id);
    if (encounter != null) {
      await encounterRepository.enemyRepository
          .deleteEnemiesByEncounterId(encounter.id);
      await encounterRepository.deleteEncounter(encounter);
    }
    await encounterRepository.deleteEncounterRewardsByQuestId(quest.id);
    await questRepository.deleteQuest(quest);
    await playerCubit.loadCharacter();
  }

  Future<void> resetCharacter() async {
    final c = state.character;
    final reset = Character(
      id: c.id,
      name: c.name,
      characterClass: c.characterClass,
      level: c.level,
      gold: 0,
      currentExp: 0,
      currentHealth: (c.level * 10) + c.characterClass.baseMaxHealth,
      currentMana: (c.level * 10) + 10,
      actionPoints: 0,
      // equipped* and activeSkillSlot* omitted -> null (unequipped, no
      // active skills). skills defaults to const [].
      dailyApEarned: 0,
      themeId: c.themeId,
    );
    final updated = await characterRepository.updateCharacter(reset);
    await equipmentRepository.deleteAllEquipmentForCharacter(updated.id);
    await characterRepository.deleteAllSkillsForCharacter(updated.id);
    await characterRepository
        .updateCharacterStats(CharacterStats(characterId: updated.id));
    emit(state.copyWith(character: updated));
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
      currentMana: c.currentMana,
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
    );
  }
}
