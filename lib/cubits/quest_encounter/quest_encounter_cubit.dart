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
  late QuestRepository questRepository;
  late QuestService questService;
  late EncounterRepository encounterRepository;
  late QuestZoneRepository questZoneRepository;
  late EnemyRepository enemyRepository;

  QuestEncounterCubit({required Quest quest, required Database db})
      : super(QuestEncounterState(
            quest: quest, status: QuestEncounterStatus.initial)) {
    questRepository = QuestRepository(db: db);
    encounterRepository = EncounterRepository(db: db);
    questZoneRepository = QuestZoneRepository(db: db);
    enemyRepository = EnemyRepository(db: db);
    questService = QuestService(db: db);
    init();
  }

  Future<void> init() async {
    final encounter =
        await encounterRepository.getEncounterByQuestId(state.quest.id);
    if (encounter != null) {
      emit(state.copyWith(
          encounter: encounter, status: _determineEncounterStatus(encounter)));
    } else {
      emit(state.copyWith(status: QuestEncounterStatus.generating));

      final verboseQuestZone = await questZoneRepository.getQuestZone(
          state.quest.zone.id, true, true);
      final newEncounter =
          await questService.generateEncounter(state.quest, verboseQuestZone);
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
    if (encounter.encounterCompleted) {
      return QuestEncounterStatus.completed;
    } else if (encounter.enemies.isNotEmpty &&
        encounter.enemies.every((enemy) => enemy.currentHealth <= 0)) {
      return QuestEncounterStatus.completed;
    } else {
      return QuestEncounterStatus.inProgress;
    }
  }
}
