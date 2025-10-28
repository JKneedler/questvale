import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/character_data_state.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/services/combat_service.dart';
import 'package:sqflite/sqflite.dart';

class CharacterDataCubit extends Cubit<CharacterDataState> {
  late CharacterRepository characterRepository;
  late QuestRepository questRepository;
  late CombatService combatService;

  CharacterDataCubit({required Database db})
      : super(CharacterDataState(
          character: null,
        )) {
    characterRepository = CharacterRepository(db: db);
    questRepository = QuestRepository(db: db);
    combatService = CombatService(db: db);
    loadCharacter();
  }

  Future<void> loadCharacter() async {
    final character = await characterRepository.getSingleCharacter();
    final combatStats = await combatService.getCharacterCombatStats(character);
    emit(state.copyWith(character: character, combatStats: combatStats));
  }

  Future<void> updateQuest() async {
    final character = state.character;
    if (character != null) {
      emit(state.copyWith(character: character));
    }
  }

  Future<void> deleteQuest() async {
    final character = state.character;
    if (character != null) {
      emit(state.copyWith(character: character));
    }
  }

  Future<void> recoverCharacter() async {
    final character = state.character;
    if (character != null) {
      final maxHealth = state.combatStats?.maxHealth ?? 0;
      final maxResource = state.combatStats?.maxResource ?? 0;
      final recoveredCharacter = character.copyWith(
          currentHealth: maxHealth, currentMana: maxResource);
      await characterRepository.updateCharacter(recoveredCharacter);
      loadCharacter();
    }
  }
}
