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

  // Gear is always current now (see the Combat & Questing Redesign ticket —
  // equipment/skills management moved onto Town Square's own scrollable
  // list), so Quest Board's only job left is picking a zone and starting
  // the quest — no more separate Gear Up step in between.
  Future<void> onBeginQuest(BuildContext context, QuestZone questZone) async {
    // Guards against a double-tap firing this twice before the first
    // insert lands — QuestRepository.getQuest throws if a character ends
    // up with more than one quest row (see the nav-bar-visible follow-up
    // entry in the vault ticket), so this isn't just a cosmetic guard.
    if (state.questBoardState == QuestBoardStates.creatingQuest) return;

    final character = context.read<PlayerCubit>().state.character;
    if (character == null) return;

    emit(state.copyWith(
        questBoardState: QuestBoardStates.creatingQuest,
        selectedQuestZone: questZone));

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
