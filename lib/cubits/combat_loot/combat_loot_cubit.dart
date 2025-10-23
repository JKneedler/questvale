import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/combat_loot/combat_loot_state.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:sqflite/sqflite.dart';

class CombatLootCubit extends Cubit<CombatLootState> {
  final Encounter encounter;
  late EncounterRepository encounterRepository;

  CombatLootCubit({required this.encounter, required Database db})
      : super(CombatLootState()) {
    encounterRepository = EncounterRepository(db: db);
    init();
  }

  Future<void> init() async {
    final encounterReward =
        await encounterRepository.getEncounterRewardByEncounterId(encounter.id);
    if (encounterReward != null) {
      emit(
        state.copyWith(
          encounterReward: encounterReward,
          firstPlay: encounterReward.createdAt.millisecondsSinceEpoch >
              DateTime.now().millisecondsSinceEpoch -
                  ENCOUNTER_FIRST_PLAY_DELAY,
        ),
      );
    }
  }
}
