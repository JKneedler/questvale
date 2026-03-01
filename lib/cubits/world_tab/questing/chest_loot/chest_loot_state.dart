import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/encounter_reward.dart';

class ChestLootState extends Equatable {
  final EncounterReward? chestReward;
  const ChestLootState({this.chestReward});

  ChestLootState copyWith({
    EncounterReward? chestReward,
  }) {
    return ChestLootState(
      chestReward: chestReward ?? this.chestReward,
    );
  }

  @override
  List<Object?> get props => [chestReward];
}
