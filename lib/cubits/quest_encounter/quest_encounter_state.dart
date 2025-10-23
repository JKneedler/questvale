import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/encounter.dart';

enum QuestEncounterStatus {
  initial,
  generating,
  inProgress,
  completed,
}

class QuestEncounterState extends Equatable {
  final QuestEncounterStatus status;
  final Encounter? encounter;
  final bool darkened;

  const QuestEncounterState({
    required this.status,
    this.encounter,
    this.darkened = false,
  });

  QuestEncounterState copyWith({
    QuestEncounterStatus? status,
    Encounter? encounter,
    bool? darkened,
  }) {
    return QuestEncounterState(
      status: status ?? this.status,
      encounter: encounter ?? this.encounter,
      darkened: darkened ?? this.darkened,
    );
  }

  @override
  List<Object?> get props => [status, encounter, darkened];
}
