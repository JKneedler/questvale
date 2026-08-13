import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_state.dart';
import 'package:questvale/data/models/mage_motes.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/services/skill_service.dart';
import 'package:sqflite/sqflite.dart';

class PlayerCubit extends Cubit<PlayerState> {
  late CharacterRepository characterRepository;
  late SkillService skillService;

  PlayerCubit({required Database db, required GameData gameData})
      : super(PlayerState(
          character: null,
          playerSkills: null,
          playerCombatStats: null,
        )) {
    characterRepository = CharacterRepository(db: db);
    skillService = SkillService(gameData: gameData);
    loadCharacter();
  }

  Future<void> loadCharacter() async {
    final character = await characterRepository.getSingleCharacter();
    final playerSkills = PlayerSkills(
      investedActiveSkills: [],
      activeSkillSlot1: character.activeSkillSlot1 != null
          ? skillService.getSkillById(character.activeSkillSlot1!.skillId,
              level: character.activeSkillSlot1!.level)
          : null,
      activeSkillSlot2: character.activeSkillSlot2 != null
          ? skillService.getSkillById(character.activeSkillSlot2!.skillId,
              level: character.activeSkillSlot2!.level)
          : null,
      activeSkillSlot3: character.activeSkillSlot3 != null
          ? skillService.getSkillById(character.activeSkillSlot3!.skillId,
              level: character.activeSkillSlot3!.level)
          : null,
      activeSkillSlot4: character.activeSkillSlot4 != null
          ? skillService.getSkillById(character.activeSkillSlot4!.skillId,
              level: character.activeSkillSlot4!.level)
          : null,
      activeSkillSlot5: character.activeSkillSlot5 != null
          ? skillService.getSkillById(character.activeSkillSlot5!.skillId,
              level: character.activeSkillSlot5!.level)
          : null,
    );
    final equipments = character.equippedEquipmentList;
    // There's no "equip slot" concept for passives — having the
    // CharacterSkill row is having it invested/tracked (see the Skill
    // System Foundations ticket, subtask 5). Elemental Affinity is the
    // only one that actually returns anything yet.
    final playerCombatStats = PlayerCombatStats(
      playerLevel: character.level,
      characterClass: character.characterClass,
      equipments: equipments,
      passiveModifiers: skillService.passiveModifiersFor(character),
    );
    final MageMotes? mageMotes = character.characterClass == CharacterClass.mage
        ? await characterRepository.getMageMotes(character.id)
        : null;
    if (!isClosed) {
      emit(state.copyWith(
          character: character,
          playerSkills: playerSkills,
          playerCombatStats: playerCombatStats,
          mageMotes: mageMotes));
    }
  }
}
