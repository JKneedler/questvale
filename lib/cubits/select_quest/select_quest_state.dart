import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/quest_zone.dart';

enum QuestCreateStates {
  notCreating,
  creating,
  createdSuccess,
  createdFailed,
}

class SelectQuestState {
  final Character? character;
  final List<QuestZone> questZones;
  final int selectedQuestZoneIndex;
  final QuestCreateStates questCreateState;

  const SelectQuestState({
    this.character,
    this.questZones = const [],
    this.selectedQuestZoneIndex = -1,
    this.questCreateState = QuestCreateStates.notCreating,
  });

  SelectQuestState copyWith(
      {Character? character,
      List<QuestZone>? questZones,
      int? selectedQuestZoneIndex,
      QuestCreateStates? questCreateState}) {
    return SelectQuestState(
      character: character ?? this.character,
      questZones: questZones ?? this.questZones,
      selectedQuestZoneIndex:
          selectedQuestZoneIndex ?? this.selectedQuestZoneIndex,
      questCreateState: questCreateState ?? this.questCreateState,
    );
  }
}
