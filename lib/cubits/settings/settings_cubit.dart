import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/settings/settings_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:questvale/services/equipment_service.dart';
import 'package:sqflite/sqflite.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final Database db;
  late EquipmentRepository equipmentRepository;

  SettingsCubit({required this.db, required Character character})
      : super(SettingsState(
            character: character,
            questsNum: 0,
            encountersNum: 0,
            enemiesNum: 0,
            tableInfos: [])) {
    loadSettings();
    equipmentRepository = EquipmentRepository(db: db);
  }

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
    // final questZones = context.read<GameData>().questZones;
    // for (var i = 0; i < 10; i++) {
    //   final equipment = equipmentService.generateRandomTestEquipment(
    //       state.character, questZones[0], EncounterType.genericCombat);
    //   print(equipment);
    //   await equipmentRepository.insertEquipment(equipment);
    // }
  }
}
