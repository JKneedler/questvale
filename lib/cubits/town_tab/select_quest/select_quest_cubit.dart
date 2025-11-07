import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/town_tab/select_quest/select_quest_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/providers/game_data_models/quest_zone.dart';
import 'package:questvale/services/quest_service.dart';
import 'package:sqflite/sqflite.dart';

class SelectQuestCubit extends Cubit<SelectQuestState> {
  late QuestService questService;
  final List<QuestZone> questZones;
  final Character character;

  SelectQuestCubit(
      {required Database db, required this.questZones, required this.character})
      : super(const SelectQuestState()) {
    questService = QuestService(db: db);
  }

  Future<void> toggleQuestZone(int index) async {
    final newIndex = state.selectedQuestZoneIndex == index ? -1 : index;
    emit(state.copyWith(selectedQuestZoneIndex: newIndex));
  }

  Future<void> beginQuest() async {
    emit(state.copyWith(questCreateState: QuestCreateStates.creating));
    if (state.selectedQuestZoneIndex == -1 ||
        state.selectedQuestZoneIndex >= questZones.length) {
      return;
    }
    final questZone = questZones[state.selectedQuestZoneIndex];
    final success =
        await questService.beginQuestGeneration(character, questZone);
    emit(
      state.copyWith(
          questCreateState: success
              ? QuestCreateStates.createdSuccess
              : QuestCreateStates.createdFailed),
    );
  }
}
