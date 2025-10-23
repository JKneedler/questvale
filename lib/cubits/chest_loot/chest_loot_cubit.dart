import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/chest_loot/chest_loot_state.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:sqflite/sqflite.dart';

class ChestLootCubit extends Cubit<ChestLootState> {
  final Encounter encounter;
  late EncounterRepository encounterRepository;

  ChestLootCubit({required this.encounter, required Database db})
      : super(ChestLootState()) {
    encounterRepository = EncounterRepository(db: db);
    init();
  }

  Future<void> init() async {
    final chestReward =
        await encounterRepository.getEncounterRewardByEncounterId(encounter.id);
    if (chestReward != null) {
      emit(
        state.copyWith(
          chestReward: chestReward,
          firstPlay: chestReward.createdAt.millisecondsSinceEpoch >
              DateTime.now().millisecondsSinceEpoch -
                  ENCOUNTER_FIRST_PLAY_DELAY,
        ),
      );
    }
  }
}
