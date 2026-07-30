import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/settings/settings_state.dart';
import 'package:questvale/cubits/theme/theme_cubit.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:questvale/services/equipment_service.dart';
import 'package:sqflite/sqflite.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final Database db;
  final GameData gameData;
  final PlayerCubit playerCubit;
  final ThemeCubit themeCubit;
  late EquipmentRepository equipmentRepository;
  late CharacterRepository characterRepository;

  SettingsCubit(
      {required this.db,
      required this.gameData,
      required this.playerCubit,
      required this.themeCubit,
      required Character character})
      : super(SettingsState(
            character: character,
            questsNum: 0,
            encountersNum: 0,
            enemiesNum: 0,
            tableInfos: [])) {
    loadSettings();
    equipmentRepository = EquipmentRepository(db: db);
    characterRepository = CharacterRepository(db: db);
  }

  void setTheme(String themeId) => themeCubit.setTheme(themeId);

  Future<void> loadSettings() async {
    final tableInfos = [
      TableInfo(
          tableType: TableType.quests,
          numRows: await getTableLength(TableType.quests)),
      TableInfo(
          tableType: TableType.encounters,
          numRows: await getTableLength(TableType.encounters)),
      TableInfo(
          tableType: TableType.enemies,
          numRows: await getTableLength(TableType.enemies)),
      TableInfo(
          tableType: TableType.encounterRewards,
          numRows: await getTableLength(TableType.encounterRewards)),
      TableInfo(
          tableType: TableType.characterTags,
          numRows: await getTableLength(TableType.characterTags)),
      TableInfo(
          tableType: TableType.todos,
          numRows: await getTableLength(TableType.todos)),
      TableInfo(
          tableType: TableType.todoTags,
          numRows: await getTableLength(TableType.todoTags)),
      TableInfo(
          tableType: TableType.todoReminders,
          numRows: await getTableLength(TableType.todoReminders)),
      TableInfo(
          tableType: TableType.characters,
          numRows: await getTableLength(TableType.characters),
          isDeletable: false),
      TableInfo(
          tableType: TableType.equipments,
          numRows: await getTableLength(TableType.equipments)),
      TableInfo(
          tableType: TableType.statModifiers,
          numRows: await getTableLength(TableType.statModifiers)),
      TableInfo(
          tableType: TableType.equipmentEncounterRewards,
          numRows: await getTableLength(TableType.equipmentEncounterRewards)),
    ];
    if (!isClosed) {
      emit(state.copyWith(tableInfos: tableInfos));
    }
  }

  Future<int> getTableLength(TableType tableType) async {
    final tableLength = await db.query(tableType.tableName);
    return tableLength.length;
  }

  Future<void> deleteTableContents(TableInfo tableInfo) async {
    if (tableInfo.isDeletable) {
      await db.delete(tableInfo.tableType.tableName);
    }
    loadSettings();
  }

  Future<void> logTableContents(TableType tableType) async {
    final tableContents = await db.query(tableType.tableName);
    for (var content in tableContents) {
      print(content);
    }
  }

  Future<void> generateLoot() async {
    final equipmentService = EquipmentService(db: db);
    final questZones = gameData.questZones;
    for (var i = 0; i < 10; i++) {
      final equipment = equipmentService.generateRandomTestEquipment(
          state.character, questZones[0], EncounterType.genericCombat);
      await equipmentRepository.insertEquipment(equipment);
    }
  }

  Future<void> resetAp() async {
    final updated = await characterRepository.updateCharacter(
      state.character.copyWith(actionPoints: 0, dailyApEarned: 0),
    );
    emit(state.copyWith(character: updated));
    // PlayerCubit holds the canonical Character used elsewhere (world_tab,
    // todo_tab's AP display) — it won't pick up this change until reloaded.
    await playerCubit.loadCharacter();
  }
}
