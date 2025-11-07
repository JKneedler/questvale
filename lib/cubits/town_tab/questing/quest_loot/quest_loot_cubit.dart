import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/town_tab/questing/quest_loot/quest_loot_state.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:sqflite/sqflite.dart';

class QuestLootCubit extends Cubit<QuestLootState> {
  final Quest quest;
  late EncounterRepository encounterRepository;

  QuestLootCubit({required this.quest, required Database db})
      : super(QuestLootState(gold: 0, xp: 0, equipment: [])) {
    encounterRepository = EncounterRepository(db: db);
    init();
  }

  Future<void> init() async {
    final encounterRewards =
        await encounterRepository.getEncounterRewardsByQuestId(quest.id);
    final gold = encounterRewards.fold(
        0, (sum, encounterReward) => sum + encounterReward.gold);
    final xp = encounterRewards.fold(
        0, (sum, encounterReward) => sum + encounterReward.xp);
    final equipment = encounterRewards.fold<List<Equipment>>(
        [],
        (list, encounterReward) =>
            [...list, ...encounterReward.equipmentRewards]);
    if (!isClosed) {
      emit(state.copyWith(gold: gold, xp: xp, equipment: equipment));
    }
  }
}
