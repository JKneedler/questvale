import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/quest.dart';

class CharacterDataState extends Equatable {
  final Character? character;
  final Quest? quest;

  const CharacterDataState({
    required this.character,
    required this.quest,
  });

  CharacterDataState copyWith({
    Character? character,
    Quest? quest,
  }) {
    return CharacterDataState(
      character: character ?? this.character,
      quest: quest ?? this.quest,
    );
  }

  @override
  List<Object?> get props => [character, quest];
}
