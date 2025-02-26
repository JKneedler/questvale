import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';

class InventoryOverviewState extends Equatable {
  final Character? character;

  const InventoryOverviewState({this.character});

  InventoryOverviewState copyWith({
    Character? character,
  }) {
    return InventoryOverviewState(
      character: character ?? this.character,
    );
  }

  @override
  List<Object?> get props => [
        character,
      ];
}
