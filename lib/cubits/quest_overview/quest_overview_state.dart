import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/quest.dart';

class QuestOverviewState extends Equatable {
  final Character? character;
  final Quest? quest;

  const QuestOverviewState({this.character, this.quest});

  QuestOverviewState copyWith({
    Character? character,
    Quest? quest,
  }) {
    return QuestOverviewState(
      character: character ?? this.character,
      quest: quest ?? this.quest,
    );
  }

  @override
  List<Object?> get props => [character, quest];
}
