import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/quest.dart';

enum TownLocation {
  townSquare,
  questBoard,
  quest,
  shop,
  guildHall,
  lab,
  forge,
  gemforge,
  reliquary;
}

class TownState extends Equatable {
  final TownLocation currentLocation;
  final Quest? quest;

  const TownState({required this.currentLocation, this.quest});

  TownState copyWith({
    TownLocation? currentLocation,
    Quest? quest,
  }) {
    return TownState(
      currentLocation: currentLocation ?? this.currentLocation,
      quest: quest ?? this.quest,
    );
  }

  @override
  List<Object?> get props => [currentLocation, quest];
}
