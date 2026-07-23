import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/quest_board_state.dart';
import 'package:questvale/data/providers/game_data_models/quest_zone.dart';
import 'package:questvale/services/quest_service.dart';
import 'package:sqflite/sqflite.dart';

class QuestBoardCubit extends Cubit<QuestBoardState> {
  late QuestService questService;

  QuestBoardCubit({required Database db}) : super(const QuestBoardState()) {
    questService = QuestService(db: db);
  }

  void onQuestZoneSelected(QuestZone questZone) {
    emit(state.copyWith(
        questBoardState: QuestBoardStates.gearingUp,
        selectedQuestZone: questZone));
  }

  void onGoBackWhileGearingUp() {
    emit(state.copyWith(
        questBoardState: QuestBoardStates.selectingQuestZone,
        selectedQuestZone: null));
  }

  Future<void> onBeginQuest(BuildContext context) async {
    final character = context.read<PlayerCubit>().state.character;
    if (character == null) return;

    emit(state.copyWith(questBoardState: QuestBoardStates.creatingQuest));
    final questZone = state.selectedQuestZone;
    if (questZone == null) return;

    final success =
        await questService.beginQuestGeneration(character, questZone);
    if (success) {
      emit(state.copyWith(questBoardState: QuestBoardStates.questCreated));
    } else {
      emit(state.copyWith(
          questBoardState: QuestBoardStates.questCreationFailed));
    }
  }
}
