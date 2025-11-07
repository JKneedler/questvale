import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/town_tab/questing/quest_encounter/quest_encounter_state.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/providers/game_data_models/quest_zone.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/services/quest_service.dart';
import 'package:sqflite/sqflite.dart';

class QuestEncounterCubit extends Cubit<QuestEncounterState> {
  late QuestRepository questRepository;
  late QuestService questService;
  late EncounterRepository encounterRepository;
  late EnemyRepository enemyRepository;
  late CharacterRepository characterRepository;

  final QuestZone questZone;

  QuestEncounterCubit(
      {required Quest quest,
      required QuestStatus initialQuestStatus,
      required Database db,
      required this.questZone})
      : super(QuestEncounterState(
            quest: quest, questStatus: initialQuestStatus)) {
    questRepository = QuestRepository(db: db);
    encounterRepository = EncounterRepository(db: db);
    enemyRepository = EnemyRepository(db: db);
    characterRepository = CharacterRepository(db: db);
    questService = QuestService(db: db);
    init();
  }

  Future<void> init() async {
    loadQuest();
  }

  Future<void> loadQuest() async {
    final quest = await questRepository.getQuest(state.quest.characterId);
    if (quest == null) {
      throw Exception('Quest not found');
    }
    final encounter = await encounterRepository.getEncounterByQuestId(quest.id);
    if (quest.completedAt != null) {
      emit(state.copyWith(
          questStatus: QuestStatus.questCompleted, quest: quest));
    } else if (encounter != null) {
      if (encounter.completedAt != null) {
        emit(state.copyWith(
            questStatus: QuestStatus.encounterCompleted,
            encounter: encounter,
            quest: quest));
      } else {
        emit(state.copyWith(
            questStatus: QuestStatus.encounterInProgress,
            encounter: encounter,
            quest: quest));
      }
    } else if (quest.curEncounterNum == 0) {
      if (quest.curFloor == 1) {
        emit(state.copyWith(questStatus: QuestStatus.questBegin, quest: quest));
      } else {
        emit(state.copyWith(questStatus: QuestStatus.floorBegin, quest: quest));
      }
    } else {
      final newEncounter = await _generateEncounter();
      emit(state.copyWith(
          questStatus: QuestStatus.encounterInProgress,
          encounter: newEncounter,
          quest: quest));
    }
  }

  Future<Encounter> _generateEncounter() async {
    final quest = await questRepository.getQuest(state.quest.characterId);
    if (quest == null) {
      throw Exception('Quest not found');
    }
    final newEncounter = await questService.generateEncounter(quest, questZone);
    await encounterRepository.insertEncounter(newEncounter);
    for (var enemy in newEncounter.enemies) {
      await enemyRepository.insertEnemy(enemy);
    }
    return newEncounter;
  }

  void toggleDarkened(bool darkened) {
    emit(state.copyWith(darkened: darkened));
  }

  Future<void> completeEncounter() async {
    final quest = state.quest;
    final character =
        await characterRepository.getCharacterById(quest.characterId);
    if (state.encounter != null) {
      if (state.encounter!.encounterType == EncounterType.chest) {
        final encounterReward = await questService.generateEncounterReward(
            character, state.encounter!, quest, questZone);
        await encounterRepository.insertEncounterReward(encounterReward);
        await characterRepository.updateCharacter(character.copyWith(
          currentExp: character.currentExp + encounterReward.xp,
          gold: character.gold + encounterReward.gold,
        ));
      } else {
        final encounterReward = await questService.generateEncounterReward(
            character, state.encounter!, quest, questZone);
        await encounterRepository.insertEncounterReward(encounterReward);
        await characterRepository.updateCharacter(character.copyWith(
          currentExp: character.currentExp + encounterReward.xp,
          gold: character.gold + encounterReward.gold,
        ));
      }
      await encounterRepository.updateEncounter(
          state.encounter!.copyWith(completedAt: DateTime.now()));
      loadQuest();
    }
  }

  Future<void> nextEncounter() async {
    final quest = state.quest;
    await _cleanEncounter();
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
        final updatedQuest = quest.copyWith(curFloor: curFloor + 1);
        await questRepository.updateQuest(updatedQuest);
        loadQuest();
      } else {
        await questRepository
            .updateQuest(quest.copyWith(completedAt: DateTime.now()));
        loadQuest();
      }
    }
  }

  Future<void> _cleanEncounter() async {
    final quest = state.quest;
    final encounter = await encounterRepository.getEncounterByQuestId(quest.id);
    if (encounter != null) {
      await enemyRepository.deleteEnemiesByEncounterId(encounter.id);
      await encounterRepository.deleteEncounter(encounter);
    }
  }

  Future<void> fleeQuest() async {
    final quest = state.quest;
    await questRepository
        .updateQuest(quest.copyWith(completedAt: DateTime.now()));
    emit(state.copyWith(questStatus: QuestStatus.questDeleted));
  }

  Future<void> finishQuest() async {
    final quest = state.quest;
    await questRepository.deleteQuest(quest);
    final encounter = await encounterRepository.getEncounterByQuestId(quest.id);
    await encounterRepository.deleteEncounterRewardsByQuestId(quest.id);
    if (encounter != null) {
      await encounterRepository.deleteEncounter(encounter);
      await enemyRepository.deleteEnemiesByEncounterId(encounter.id);
    }
    emit(state.copyWith(questStatus: QuestStatus.questDeleted));
  }
}
