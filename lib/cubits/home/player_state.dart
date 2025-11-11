import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';

class PlayerState extends Equatable {
  final Character? character;

  const PlayerState({
    required this.character,
  });

  PlayerState copyWith({
    Character? character,
  }) {
    return PlayerState(
      character: character ?? this.character,
    );
  }

  @override
  List<Object?> get props => [character];
}
