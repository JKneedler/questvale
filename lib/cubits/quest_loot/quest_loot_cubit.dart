import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/quest_loot/quest_loot_state.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:sqflite/sqflite.dart';

class QuestLootCubit extends Cubit<QuestLootState> {
  final Quest quest;
  late QuestRepository questRepository;

  QuestLootCubit({required this.quest, required Database db})
      : super(QuestLootState()) {
    questRepository = QuestRepository(db: db);
    init();
  }

  Future<void> init() async {
    final questSummary =
        await questRepository.getQuestSummaryByQuestId(quest.id);
    if (questSummary != null) {
      emit(
        state.copyWith(
            questSummary: questSummary,
            firstPlay: quest.completedAt!.millisecondsSinceEpoch >
                DateTime.now().millisecondsSinceEpoch -
                    ENCOUNTER_FIRST_PLAY_DELAY),
      );
    }
  }
}
