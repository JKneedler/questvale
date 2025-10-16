import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/settings/settings_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:sqflite/sqflite.dart';

class SettingsCubit extends Cubit<SettingsState> {
  late QuestRepository questRepository;
  late EncounterRepository encounterRepository;
  late EnemyRepository enemyRepository;

  SettingsCubit({required Database db, required Character character})
      : super(SettingsState(
            character: character,
            questsNum: 0,
            encountersNum: 0,
            enemiesNum: 0)) {
    questRepository = QuestRepository(db: db);
    encounterRepository = EncounterRepository(db: db);
    enemyRepository = EnemyRepository(db: db);
    loadSettings();
  }

  Future<void> loadSettings() async {
    final questsNum = await questRepository.getQuestsNum();
    final encountersNum = await encounterRepository.getEncountersNum();
    final enemiesNum = await enemyRepository.getEnemiesNum();
    emit(state.copyWith(
        questsNum: questsNum,
        encountersNum: encountersNum,
        enemiesNum: enemiesNum));
  }

  Future<void> deleteQuests() async {
    await questRepository.deleteQuests();
    await loadSettings();
  }

  Future<void> deleteEncounters() async {
    await encounterRepository.deleteEncounters();
    await loadSettings();
  }

  Future<void> deleteEnemies() async {
    await enemyRepository.deleteEnemies();
    await loadSettings();
  }
}
