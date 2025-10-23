import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/quest.dart';

class QuestState extends Equatable {
  final Quest? quest;
  final bool showQuestView;

  const QuestState({this.quest, this.showQuestView = false});

  QuestState copyWith({
    Quest? quest,
    bool? showQuestView,
  }) {
    return QuestState(
      quest: quest ?? this.quest,
      showQuestView: showQuestView ?? this.showQuestView,
    );
  }

  @override
  List<Object?> get props => [quest, showQuestView];
}
