import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/character_data_state.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:sqflite/sqflite.dart';

class CharacterDataCubit extends Cubit<CharacterDataState> {
  late CharacterRepository characterRepository;
  late QuestRepository questRepository;

  CharacterDataCubit({required Database db})
      : super(CharacterDataState(
          character: null,
          quest: null,
        )) {
    characterRepository = CharacterRepository(db: db);
    questRepository = QuestRepository(db: db);
    loadCharacter();
  }

  Future<void> loadCharacter() async {
    final character = await characterRepository.getSingleCharacter();
    final quest = await questRepository.getQuest(character.id);
    print(
        'loadCharacter() \n         - CHARACTER: $character \n         - QUEST: $quest');
    emit(state.copyWith(character: character, quest: quest));
  }

  Future<void> updateQuest() async {
    final character = state.character;
    final curQuest = state.quest;
    if (character != null) {
      final quest = await questRepository.getQuest(character.id);
      if (curQuest == null && quest != null) {
        emit(state.copyWith(quest: quest));
      } else if (curQuest != null && quest == null) {
        emit(CharacterDataState(character: character, quest: null));
      } else {
        emit(state.copyWith(quest: quest));
      }
    }
  }

  Future<void> deleteQuest() async {
    final character = state.character;
    if (character != null && state.quest != null) {
      await questRepository.deleteQuest(state.quest!);
      emit(CharacterDataState(character: character, quest: null));
    }
  }
}
