import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/quest_floor_begin/quest_floor_begin_state.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';

class QuestFloorBeginCubit extends Cubit<QuestFloorBeginState> {
  final CharacterRepository characterRepository;
  final QuestRepository questRepository;

  QuestFloorBeginCubit(this.characterRepository, this.questRepository)
      : super(QuestFloorBeginState(character: null, quest: null)) {
    loadQuest();
  }

  Future<void> loadQuest() async {
    final character = await characterRepository.getSingleCharacter();
    final quest = await questRepository.getQuest(character.id);
    emit(state.copyWith(character: character, quest: quest));
  }
}
