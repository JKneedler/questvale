import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/quest_summary.dart';

class QuestLootState extends Equatable {
  final QuestSummary? questSummary;
  final bool firstPlay;
  const QuestLootState({this.questSummary, this.firstPlay = false});

  QuestLootState copyWith({
    QuestSummary? questSummary,
    bool? firstPlay,
  }) {
    return QuestLootState(
      questSummary: questSummary ?? this.questSummary,
      firstPlay: firstPlay ?? this.firstPlay,
    );
  }

  @override
  List<Object?> get props => [questSummary, firstPlay];
}
