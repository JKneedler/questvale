import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/settings/settings_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:sqflite/sqflite.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final Database db;

  SettingsCubit({required this.db, required Character character})
      : super(SettingsState(
            character: character,
            questsNum: 0,
            encountersNum: 0,
            enemiesNum: 0,
            tableInfos: [])) {
    loadSettings();
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
          tableType: TableType.enemyData,
          numRows: await getTableLength(TableType.enemyData)),
      TableInfo(
          tableType: TableType.enemyAttackData,
          numRows: await getTableLength(TableType.enemyAttackData)),
      TableInfo(
          tableType: TableType.enemyDropData,
          numRows: await getTableLength(TableType.enemyDropData)),
      TableInfo(
          tableType: TableType.encounterRewards,
          numRows: await getTableLength(TableType.encounterRewards)),
      TableInfo(
          tableType: TableType.questZones,
          numRows: await getTableLength(TableType.questZones)),
      TableInfo(
          tableType: TableType.questSummaries,
          numRows: await getTableLength(TableType.questSummaries)),
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
          numRows: await getTableLength(TableType.characters)),
    ];
    emit(state.copyWith(tableInfos: tableInfos));
  }

  Future<int> getTableLength(TableType tableType) async {
    final tableLength = await db.query(tableType.tableName);
    return tableLength.length;
  }

  Future<void> deleteTableContents(TableType tableType) async {}

  Future<void> logTableContents(TableType tableType) async {
    final tableContents = await db.query(tableType.tableName);
    for (var content in tableContents) {
      print(content);
    }
  }
}
