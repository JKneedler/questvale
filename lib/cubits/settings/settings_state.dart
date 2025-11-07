import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';

enum TableType {
  characters,
  characterTags,
  todos,
  todoTags,
  todoReminders,
  quests,
  questZones,
  encounters,
  encounterRewards,
  enemies,
  enemyData,
  enemyAttackData,
  enemyDropData,
  equipments,
  statModifiers,
  equipmentEncounterRewards;

  String get tableName {
    switch (this) {
      case TableType.characters:
        return 'Characters';
      case TableType.characterTags:
        return 'CharacterTags';
      case TableType.todos:
        return 'Todos';
      case TableType.todoTags:
        return 'TodoTags';
      case TableType.todoReminders:
        return 'TodoReminders';
      case TableType.quests:
        return 'Quests';
      case TableType.questZones:
        return 'QuestZones';
      case TableType.encounters:
        return 'Encounters';
      case TableType.encounterRewards:
        return 'EncounterRewards';
      case TableType.enemies:
        return 'Enemies';
      case TableType.enemyData:
        return 'EnemyData';
      case TableType.enemyAttackData:
        return 'EnemyAttackData';
      case TableType.enemyDropData:
        return 'EnemyDropData';
      case TableType.equipments:
        return 'Equipments';
      case TableType.statModifiers:
        return 'StatModifiers';
      case TableType.equipmentEncounterRewards:
        return 'EquipmentEncounterRewards';
    }
  }
}

class TableInfo {
  final TableType tableType;
  final int numRows;
  final bool isDeletable;
  const TableInfo(
      {required this.tableType,
      required this.numRows,
      this.isDeletable = true});
}

class SettingsState extends Equatable {
  final Character character;
  final int questsNum;
  final int encountersNum;
  final int enemiesNum;
  final List<TableInfo> tableInfos;

  const SettingsState({
    required this.character,
    required this.questsNum,
    required this.encountersNum,
    required this.enemiesNum,
    required this.tableInfos,
  });

  SettingsState copyWith({
    Character? character,
    int? questsNum,
    int? encountersNum,
    int? enemiesNum,
    List<TableInfo>? tableInfos,
  }) {
    return SettingsState(
      character: character ?? this.character,
      questsNum: questsNum ?? this.questsNum,
      encountersNum: encountersNum ?? this.encountersNum,
      enemiesNum: enemiesNum ?? this.enemiesNum,
      tableInfos: tableInfos ?? this.tableInfos,
    );
  }

  @override
  List<Object?> get props =>
      [character, questsNum, encountersNum, enemiesNum, tableInfos];
}
