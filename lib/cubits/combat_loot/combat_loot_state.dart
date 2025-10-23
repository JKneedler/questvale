import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/encounter_reward.dart';

class CombatLootState extends Equatable {
  final EncounterReward? encounterReward;
  final bool firstPlay;
  const CombatLootState({this.encounterReward, this.firstPlay = false});

  CombatLootState copyWith({
    EncounterReward? encounterReward,
    bool? firstPlay,
  }) {
    return CombatLootState(
      encounterReward: encounterReward ?? this.encounterReward,
      firstPlay: firstPlay ?? this.firstPlay,
    );
  }

  @override
  List<Object?> get props => [encounterReward, firstPlay];
}
