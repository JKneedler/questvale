import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';

class CharacterState extends Equatable {
  final Character? character;

  const CharacterState({this.character});

  CharacterState copyWith({Character? character}) {
    return CharacterState(character: character ?? this.character);
  }

  @override
  List<Object?> get props => [character];
}
