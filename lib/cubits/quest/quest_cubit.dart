import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/quest/quest_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/services/quest_service.dart';
import 'package:sqflite/sqflite.dart';

class QuestCubit extends Cubit<QuestState> {
  final Character character;
  late QuestService questService;
  late QuestRepository questRepository;
  late EncounterRepository encounterRepository;
  late EnemyRepository enemyRepository;

  QuestCubit(
      {required this.character,
      required Database db,
      required bool showQuestView})
      : super(QuestState(showQuestView: showQuestView)) {
    questRepository = QuestRepository(db: db);
    encounterRepository = EncounterRepository(db: db);
    enemyRepository = EnemyRepository(db: db);
    questService = QuestService(db: db);
    init();
  }

  Future<void> init() async {
    loadQuest();
  }

  void showQuestView() {
    emit(state.copyWith(showQuestView: true));
  }

  void hideQuestView() {
    emit(state.copyWith(showQuestView: false));
  }

  Future<void> loadQuest() async {
    final quest = await questRepository.getQuest(character.id);
    if (quest == null) {
      emit(QuestState(quest: null, showQuestView: false));
    } else {
      emit(state.copyWith(quest: quest));
    }
  }

  Future<void> onCreateQuest() async {
    final quest = await questRepository.getQuest(character.id);
    emit(state.copyWith(quest: quest, showQuestView: true));
  }

  Future<void> nextEncounter() async {
    final quest = state.quest;
    if (quest != null) {
      await cleanEncounter();
      final curEncounterNum = quest.curEncounterNum;
      final numEncountersCurFloor = quest.numEncountersCurFloor;
      if (curEncounterNum < numEncountersCurFloor) {
        await questRepository
            .updateQuest(quest.copyWith(curEncounterNum: curEncounterNum + 1));
        loadQuest();
      } else {
        final curFloor = quest.curFloor;
        final numFloors = quest.numFloors;
        if (curFloor < numFloors) {
          await questRepository
              .updateQuest(quest.copyWith(curFloor: curFloor + 1));
          loadQuest();
        } else {
          print('Quest is finished');
          await questRepository
              .updateQuest(quest.copyWith(completedAt: DateTime.now()));
          loadQuest();
        }
      }
    }
  }

  Future<void> cleanEncounter() async {
    final quest = state.quest;
    if (quest != null) {
      final encounter =
          await encounterRepository.getEncounterByQuestId(quest.id);
      if (encounter != null) {
        final encounterReward = await encounterRepository
            .getEncounterRewardByEncounterId(encounter.id);
        if (encounterReward != null) {
          final questSummary =
              await questRepository.getQuestSummaryByQuestId(quest.id);
          if (questSummary != null) {
            await questRepository.updateQuestSummary(questSummary.copyWith(
                xp: questSummary.xp + encounterReward.xp,
                gold: questSummary.gold + encounterReward.gold));
          }
          await encounterRepository.deleteEncounterReward(encounterReward);
        }
        await enemyRepository.deleteEnemiesByEncounterId(encounter.id);
        await encounterRepository.deleteEncounter(encounter);
      }
    }
  }

  Future<void> fleeQuest() async {
    final quest = state.quest;
    if (quest != null) {
      await questRepository
          .updateQuest(quest.copyWith(completedAt: DateTime.now()));
      loadQuest();
    }
  }

  Future<void> finishQuest() async {
    final quest = state.quest;
    if (quest != null) {
      await questRepository.deleteQuest(quest);
      await questRepository.deleteQuestSummaryByQuestId(quest.id);
      final encounter =
          await encounterRepository.getEncounterByQuestId(quest.id);
      if (encounter != null) {
        await encounterRepository.deleteEncounter(encounter);
        await encounterRepository
            .deleteEncounterRewardByEncounterId(encounter.id);
        await enemyRepository.deleteEnemiesByEncounterId(encounter.id);
      }
      loadQuest();
    }
  }
}
