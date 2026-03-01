import 'package:equatable/equatable.dart';

enum TownLocation {
  townSquare,
  questBoard,
  shop,
  guildHall,
  lab,
  forge,
  gemforge,
  reliquary;
}

class TownState extends Equatable {
  final TownLocation currentLocation;

  const TownState({required this.currentLocation});

  TownState copyWith({
    TownLocation? currentLocation,
  }) {
    return TownState(
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }

  @override
  List<Object?> get props => [currentLocation];
}
