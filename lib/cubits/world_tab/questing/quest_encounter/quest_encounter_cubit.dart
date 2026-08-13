import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/world_tab/questing/quest_encounter/quest_encounter_state.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/providers/game_data_models/quest_zone.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/services/enemy_attack_scheduling_service.dart';
import 'package:questvale/services/leveling_service.dart';
import 'package:questvale/services/notification_service.dart';
import 'package:questvale/services/quest_service.dart';
import 'package:sqflite/sqflite.dart';

class QuestEncounterCubit extends Cubit<QuestEncounterState> {
  late QuestRepository questRepository;
  late QuestService questService;
  late EncounterRepository encounterRepository;
  late EnemyRepository enemyRepository;
  late CharacterRepository characterRepository;
  late EnemyAttackSchedulingService enemyAttackSchedulingService;

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
    enemyAttackSchedulingService = EnemyAttackSchedulingService(db: db);
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
      final enemyData =
          questZone.enemies.firstWhereOrNull((d) => d.id == enemy.enemyDataId);
      if (enemyData != null) {
        await enemyAttackSchedulingService.scheduleNextMove(
          enemy: enemy,
          enemyData: enemyData,
          encounter: newEncounter,
        );
      }
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
      // encounterType (chest vs. combat) used to branch here, but both
      // branches computed the exact same reward the exact same way —
      // collapsed to one path rather than duplicating the new level-up
      // logic below into two identical copies.
      final encounterReward = await questService.generateEncounterReward(
          character, state.encounter!, quest, questZone);
      await encounterRepository.insertEncounterReward(encounterReward);
      final levelUp = LevelingService.applyExp(
        level: character.level,
        currentExp: character.currentExp,
        expGained: encounterReward.xp,
      );
      await characterRepository.updateCharacter(character.copyWith(
        level: levelUp.level,
        currentExp: levelUp.currentExp,
        gold: character.gold + encounterReward.gold,
        skillPoints: character.skillPoints + levelUp.skillPointsGained,
      ));
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

  // Cancels any still-pending attack-incoming notifications for `encounterId`
  // before clearing its ScheduledTimers, so a defeated/abandoned encounter's
  // enemies can't notify the player about an attack that will never land.
  Future<void> _clearEncounterTimers(String encounterId) async {
    final timers = await enemyAttackSchedulingService.scheduledTimerRepository
        .getTimersByEncounterId(encounterId);
    for (final timer in timers) {
      await NotificationService().cancelEnemyAttackWarning(timer.id);
    }
    await enemyAttackSchedulingService.scheduledTimerRepository
        .deleteTimersByEncounterId(encounterId);
  }

  Future<void> _cleanEncounter() async {
    final quest = state.quest;
    final encounter = await encounterRepository.getEncounterByQuestId(quest.id);
    if (encounter != null) {
      await enemyRepository.deleteEnemiesByEncounterId(encounter.id);
      await _clearEncounterTimers(encounter.id);
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
      await _clearEncounterTimers(encounter.id);
    }
    emit(state.copyWith(questStatus: QuestStatus.questDeleted));
  }
}
