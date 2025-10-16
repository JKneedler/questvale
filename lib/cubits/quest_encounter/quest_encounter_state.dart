import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/quest.dart';

enum QuestEncounterStatus {
  initial,
  generating,
  inProgress,
  completed,
}

class QuestEncounterState extends Equatable {
  final Quest quest;
  final QuestEncounterStatus status;
  final Encounter? encounter;

  const QuestEncounterState(
      {required this.quest, required this.status, this.encounter});

  QuestEncounterState copyWith({
    Quest? quest,
    QuestEncounterStatus? status,
    Encounter? encounter,
  }) {
    return QuestEncounterState(
      quest: quest ?? this.quest,
      status: status ?? this.status,
      encounter: encounter ?? this.encounter,
    );
  }

  @override
  List<Object?> get props => [quest, status, encounter];
}
