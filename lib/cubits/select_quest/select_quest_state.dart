import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/quest_zone.dart';

class SelectQuestState {
  final Character? character;
  final List<QuestZone> questZones;
  final int selectedQuestZoneIndex;

  const SelectQuestState(
      {this.character,
      this.questZones = const [],
      this.selectedQuestZoneIndex = -1});

  SelectQuestState copyWith(
      {Character? character,
      List<QuestZone>? questZones,
      int? selectedQuestZoneIndex}) {
    return SelectQuestState(
      character: character ?? this.character,
      questZones: questZones ?? this.questZones,
      selectedQuestZoneIndex:
          selectedQuestZoneIndex ?? this.selectedQuestZoneIndex,
    );
  }
}
