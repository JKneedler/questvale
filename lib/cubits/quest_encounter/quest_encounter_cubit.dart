import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/quest_encounter/quest_encounter_state.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/data/repositories/quest_zone_repository.dart';
import 'package:questvale/services/quest_service.dart';
import 'package:sqflite/sqflite.dart';

class QuestEncounterCubit extends Cubit<QuestEncounterState> {
  final Quest quest;
  late QuestRepository questRepository;
  late QuestService questService;
  late EncounterRepository encounterRepository;
  late QuestZoneRepository questZoneRepository;
  late EnemyRepository enemyRepository;

  QuestEncounterCubit({required this.quest, required Database db})
      : super(QuestEncounterState(status: QuestEncounterStatus.initial)) {
    questRepository = QuestRepository(db: db);
    encounterRepository = EncounterRepository(db: db);
    questZoneRepository = QuestZoneRepository(db: db);
    enemyRepository = EnemyRepository(db: db);
    questService = QuestService(db: db);
    init();
  }

  Future<void> init() async {
    reloadEncounter(quest);
  }

  Future<void> reloadEncounter(Quest quest) async {
    print('Reloading encounter');
    final encounter = await encounterRepository.getEncounterByQuestId(quest.id);
    if (encounter != null) {
      emit(state.copyWith(
          encounter: encounter, status: _determineEncounterStatus(encounter)));
    } else {
      emit(state.copyWith(status: QuestEncounterStatus.generating));

      final verboseQuestZone =
          await questZoneRepository.getQuestZone(quest.zone.id, true, true);
      final newEncounter =
          await questService.generateEncounter(quest, verboseQuestZone);
      await encounterRepository.insertEncounter(newEncounter);
      for (var enemy in newEncounter.enemies) {
        await enemyRepository.insertEnemy(enemy);
      }

      emit(state.copyWith(
          encounter: newEncounter,
          status: _determineEncounterStatus(newEncounter)));
    }
  }

  QuestEncounterStatus _determineEncounterStatus(Encounter encounter) {
    if (encounter.completedAt != null) {
      return QuestEncounterStatus.completed;
    } else if (encounter.enemies.isNotEmpty &&
        encounter.enemies.every((enemy) => enemy.currentHealth <= 0)) {
      return QuestEncounterStatus.completed;
    } else {
      return QuestEncounterStatus.inProgress;
    }
  }

  void toggleDarkened(bool darkened) {
    emit(state.copyWith(darkened: darkened));
  }

  Future<void> completeEncounter() async {
    if (state.encounter != null) {
      if (state.encounter!.encounterType == EncounterType.chest) {
        final encounterReward =
            await questService.generateEncounterReward(state.encounter!);
        await encounterRepository.insertEncounterReward(encounterReward);
      } else {
        final encounterReward =
            await questService.generateEncounterReward(state.encounter!);
        await encounterRepository.insertEncounterReward(encounterReward);
      }
      await encounterRepository.updateEncounter(
          state.encounter!.copyWith(completedAt: DateTime.now()));
      reloadEncounter(quest);
    }
  }
}
