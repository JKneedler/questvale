import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/quest.dart';

enum QuestStatus {
  questBegin,
  floorBegin,
  encounterInProgress,
  encounterCompleted,
  encounterDeleted,
  questCompleted,
  questDeleted;
}

class QuestEncounterState extends Equatable {
  final Quest quest;
  final QuestStatus questStatus;
  final Encounter? encounter;
  final bool darkened;

  const QuestEncounterState({
    required this.quest,
    required this.questStatus,
    this.encounter,
    this.darkened = false,
  });

  QuestEncounterState copyWith({
    Quest? quest,
    QuestStatus? questStatus,
    Encounter? encounter,
    bool? darkened,
  }) {
    return QuestEncounterState(
      quest: quest ?? this.quest,
      questStatus: questStatus ?? this.questStatus,
      encounter: encounter ?? this.encounter,
      darkened: darkened ?? this.darkened,
    );
  }

  @override
  List<Object?> get props => [quest, questStatus, encounter, darkened];
}
