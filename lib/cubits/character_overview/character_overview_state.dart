import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';

class CharacterOverviewState extends Equatable {
  final Character? character;

  const CharacterOverviewState({this.character});

  CharacterOverviewState copyWith({
    Character? character,
  }) {
    return CharacterOverviewState(
      character: character ?? this.character,
    );
  }

  @override
  List<Object?> get props => [
        character,
      ];
}
