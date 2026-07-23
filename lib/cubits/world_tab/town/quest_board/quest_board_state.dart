import 'package:equatable/equatable.dart';
import 'package:questvale/data/providers/game_data_models/quest_zone.dart';

enum QuestBoardStates {
  selectingQuestZone,
  gearingUp,
  creatingQuest,
  questCreated,
  questCreationFailed;
}

class QuestBoardState extends Equatable {
  final QuestBoardStates questBoardState;
  final QuestZone? selectedQuestZone;

  const QuestBoardState({
    this.questBoardState = QuestBoardStates.selectingQuestZone,
    this.selectedQuestZone,
  });

  QuestBoardState copyWith({
    QuestBoardStates? questBoardState,
    QuestZone? selectedQuestZone,
  }) {
    return QuestBoardState(
        questBoardState: questBoardState ?? this.questBoardState,
        selectedQuestZone: selectedQuestZone ?? this.selectedQuestZone);
  }

  @override
  List<Object?> get props => [questBoardState, selectedQuestZone];
}
