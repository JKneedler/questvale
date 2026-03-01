import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/world_tab/world_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:sqflite/sqflite.dart';

class WorldCubit extends Cubit<WorldState> {
  final Character character;
  late QuestRepository questRepository;

  WorldCubit({required this.character, required Database db})
      : super(const WorldState(quest: null)) {
    questRepository = QuestRepository(db: db);
    loadQuest();
  }

  Future<void> loadQuest() async {
    print('WorldCubit: loadQuest');
    final quest = await questRepository.getQuest(character.id);
    if (!isClosed) {
      if (quest != null) {
        emit(state.copyWith(quest: quest));
      } else {
        emit(WorldState(quest: null));
      }
    }
  }

  Future<void> onQuestCreated() async {
    final quest = await questRepository.getQuest(character.id);
    if (!isClosed && quest != null) {
      emit(state.copyWith(quest: quest));
    }
  }

  Future<void> onQuestFinished() async {
    final quest = state.quest;
    if (quest != null) {
      await questRepository.deleteQuest(quest);
    }
    if (!isClosed) {
      emit(WorldState());
    }
  }
}
