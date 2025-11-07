import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_combat_stats.dart';

class CharacterDataState extends Equatable {
  final Character? character;
  final CharacterCombatStats? combatStats;

  const CharacterDataState({
    required this.character,
    this.combatStats,
  });

  CharacterDataState copyWith({
    Character? character,
    CharacterCombatStats? combatStats,
  }) {
    return CharacterDataState(
      character: character ?? this.character,
      combatStats: combatStats ?? this.combatStats,
    );
  }

  @override
  List<Object?> get props => [character, combatStats];
}
