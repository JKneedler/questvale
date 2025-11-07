import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/town_tab/town/town_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:sqflite/sqflite.dart';

class TownCubit extends Cubit<TownState> {
  final Character character;
  late QuestRepository questRepository;

  TownCubit({required this.character, required Database db})
      : super(const TownState(currentLocation: TownLocation.townSquare)) {
    questRepository = QuestRepository(db: db);
    loadQuest();
  }

  Future<void> loadQuest() async {
    final quest = await questRepository.getQuest(character.id);
    print(quest?.toString());
    if (!isClosed) {
      if (quest != null) {
        emit(state.copyWith(quest: quest));
      } else {
        emit(TownState(currentLocation: TownLocation.townSquare, quest: null));
      }
    }
  }

  Future<void> onQuestCreated() async {
    final quest = await questRepository.getQuest(character.id);
    if (!isClosed && quest != null) {
      emit(state.copyWith(currentLocation: TownLocation.quest, quest: quest));
    }
  }

  Future<void> onQuestFinished() async {
    final quest = state.quest;
    if (quest != null) {
      await questRepository.deleteQuest(quest);
    }
    if (!isClosed) {
      emit(TownState(currentLocation: TownLocation.townSquare, quest: null));
    }
  }

  void setCurrentLocation(TownLocation location) {
    emit(state.copyWith(currentLocation: location));
  }
}
