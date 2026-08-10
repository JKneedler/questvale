import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/skills_gear_up/skills_gear_up_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_skill.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/services/skill_progression_service.dart';
import 'package:questvale/services/skill_service.dart';
import 'package:sqflite/sqflite.dart';

class SkillsGearUpCubit extends Cubit<SkillsGearUpState> {
  final Database db;
  final GameData gameData;
  final PlayerCubit playerCubit;
  late CharacterRepository characterRepository;
  late SkillProgressionService skillProgressionService;
  // Public — the detail panel needs it to build a preview BaseActiveSkill/
  // BasePassiveSkill instance for description text (see SkillsGearUpPage's
  // widgets). Owning its own instance here rather than reusing
  // PlayerCubit.skillService, same "cubit owns its own repositories"
  // convention EquipmentGearUpCubit already follows.
  late SkillService skillService;

  SkillsGearUpCubit({
    required this.db,
    required this.gameData,
    required this.playerCubit,
    required Character character,
  }) : super(SkillsGearUpState(character: character)) {
    characterRepository = CharacterRepository(db: db);
    skillProgressionService = SkillProgressionService(db: db, gameData: gameData);
    skillService = SkillService(gameData: gameData);
  }

  void toggleExpanded(String skillId) {
    final newExpandedId = state.expandedSkillId == skillId ? null : skillId;
    emit(state.withExpandedSkillId(newExpandedId));
  }

  Future<void> unlockSkill(String skillId) async {
    final result = await skillProgressionService.unlockSkill(
        character: state.character, skillId: skillId);
    if (!result.wasUnlocked) return;
    final updated = await characterRepository.getCharacterById(state.character.id);
    if (!isClosed) emit(state.copyWith(character: updated));
    await playerCubit.loadCharacter();
  }

  Future<void> upgradeSkill(String skillId) async {
    final result = await skillProgressionService.upgradeSkill(
        character: state.character, skillId: skillId);
    if (!result.wasUpgraded) return;
    final updated = await characterRepository.getCharacterById(state.character.id);
    if (!isClosed) emit(state.copyWith(character: updated));
    await playerCubit.loadCharacter();
  }

  void selectLoadoutSlot(int slotNumber) {
    emit(state.withSelectingLoadoutSlot(slotNumber));
  }

  void cancelLoadoutSelection() {
    emit(state.withSelectingLoadoutSlot(null));
  }

  // Assigns `skill` (one of the character's owned actives) into
  // activeSkillSlotN, replacing whatever was there — see the Skills UI
  // ticket's subtask 4. Character.copyWithActiveSkillSlot enforces "a
  // skill occupies at most one slot" by clearing any other slot it was
  // already in, so assigning an already-equipped skill to a new slot
  // reads as moving it rather than duplicating it.
  Future<void> assignSkillToSlot(int slotNumber, CharacterSkill skill) async {
    final updatedCharacter =
        state.character.copyWithActiveSkillSlot(slotNumber, skill);
    final persisted = await characterRepository.updateCharacter(updatedCharacter);
    if (!isClosed) {
      emit(SkillsGearUpState(
        character: persisted,
        expandedSkillId: state.expandedSkillId,
        selectingLoadoutSlot: null,
      ));
    }
    await playerCubit.loadCharacter();
  }

  // Unassigns slotNumber entirely, leaving it empty.
  Future<void> clearLoadoutSlot(int slotNumber) async {
    final updatedCharacter =
        state.character.copyWithClearedActiveSkillSlot(slotNumber);
    final persisted = await characterRepository.updateCharacter(updatedCharacter);
    if (!isClosed) {
      emit(SkillsGearUpState(
        character: persisted,
        expandedSkillId: state.expandedSkillId,
        selectingLoadoutSlot: null,
      ));
    }
    await playerCubit.loadCharacter();
  }
}
