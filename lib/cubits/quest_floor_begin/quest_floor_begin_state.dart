import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/models/character.dart';

class QuestFloorBeginState {
  final Character? character;
  final Quest? quest;

  const QuestFloorBeginState({required this.quest, required this.character});

  QuestFloorBeginState copyWith({
    Quest? quest,
    Character? character,
  }) {
    return QuestFloorBeginState(
      quest: quest ?? this.quest,
      character: character ?? this.character,
    );
  }
}
