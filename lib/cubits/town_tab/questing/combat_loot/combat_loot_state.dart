import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/encounter_reward.dart';

class CombatLootState extends Equatable {
  final EncounterReward? encounterReward;
  const CombatLootState({this.encounterReward});

  CombatLootState copyWith({
    EncounterReward? encounterReward,
  }) {
    return CombatLootState(
      encounterReward: encounterReward ?? this.encounterReward,
    );
  }

  @override
  List<Object?> get props => [encounterReward];
}
