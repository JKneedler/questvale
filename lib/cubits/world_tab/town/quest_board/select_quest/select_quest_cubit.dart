import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/select_quest/select_quest_state.dart';
import 'package:questvale/data/providers/game_data_models/quest_zone.dart';

class SelectQuestCubit extends Cubit<SelectQuestState> {
  final List<QuestZone> questZones;

  SelectQuestCubit({required this.questZones})
      : super(const SelectQuestState());

  void toggleQuestZone(int index) {
    final newIndex = state.selectedQuestZoneIndex == index ? -1 : index;
    emit(state.copyWith(selectedQuestZoneIndex: newIndex));
  }
}
