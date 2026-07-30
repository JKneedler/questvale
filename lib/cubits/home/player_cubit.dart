import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_state.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/repositories/character_repository.dart';
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
          ? skillService.getSkillById(character.activeSkillSlot1!.skillId)
          : null,
      activeSkillSlot2: character.activeSkillSlot2 != null
          ? skillService.getSkillById(character.activeSkillSlot2!.skillId)
          : null,
      activeSkillSlot3: character.activeSkillSlot3 != null
          ? skillService.getSkillById(character.activeSkillSlot3!.skillId)
          : null,
      activeSkillSlot4: character.activeSkillSlot4 != null
          ? skillService.getSkillById(character.activeSkillSlot4!.skillId)
          : null,
      activeSkillSlot5: character.activeSkillSlot5 != null
          ? skillService.getSkillById(character.activeSkillSlot5!.skillId)
          : null,
    );
    final equipments = character.equippedEquipmentList;
    final playerCombatStats = PlayerCombatStats(
      playerLevel: character.level,
      equipments: equipments,
    );
    if (!isClosed) {
      emit(state.copyWith(
          character: character,
          playerSkills: playerSkills,
          playerCombatStats: playerCombatStats));
    }
  }
}
