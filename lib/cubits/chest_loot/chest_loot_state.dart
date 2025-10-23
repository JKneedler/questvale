import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/encounter_reward.dart';

class ChestLootState extends Equatable {
  final EncounterReward? chestReward;
  final bool firstPlay;
  const ChestLootState({this.chestReward, this.firstPlay = false});

  ChestLootState copyWith({
    EncounterReward? chestReward,
    bool? firstPlay,
  }) {
    return ChestLootState(
      chestReward: chestReward ?? this.chestReward,
      firstPlay: firstPlay ?? this.firstPlay,
    );
  }

  @override
  List<Object?> get props => [chestReward, firstPlay];
}
