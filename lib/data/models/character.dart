import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character_skills.dart';
import 'package:questvale/helpers/shared_enums.dart';

class Character extends Equatable {
  static const characterTableName = 'Characters';

  static const idColumnName = 'id';
  static const nameColumnName = 'name';
  static const characterClassColumnName = 'characterClass';
  static const levelColumnName = 'level';
  static const goldColumnName = 'gold';
  static const currentExpColumnName = 'currentExp';
  static const currentHealthColumnName = 'currentHealth';
  static const currentManaColumnName = 'currentMana';
  static const actionPointsColumnName = 'actionPoints';
  static const skillSlot1ColumnName = 'skillSlot1';
  static const skillSlot2ColumnName = 'skillSlot2';
  static const skillSlot3ColumnName = 'skillSlot3';
  static const skillSlot4ColumnName = 'skillSlot4';
  static const skillSlot5ColumnName = 'skillSlot5';

  static const createTableSQL = '''
		CREATE TABLE ${Character.characterTableName}(
			${Character.idColumnName} VARCHAR PRIMARY KEY,
			${Character.nameColumnName} VARCHAR NOT NULL,
			${Character.characterClassColumnName} INTEGER NOT NULL,
			${Character.levelColumnName} INTEGER NOT NULL,
			${Character.goldColumnName} INTEGER NOT NULL,
			${Character.currentExpColumnName} INTEGER NOT NULL,
			${Character.currentHealthColumnName} INTEGER NOT NULL,
			${Character.currentManaColumnName} INTEGER NOT NULL,
			${Character.actionPointsColumnName} INTEGER NOT NULL,
      ${Character.skillSlot1ColumnName} VARCHAR,
      ${Character.skillSlot2ColumnName} VARCHAR,
      ${Character.skillSlot3ColumnName} VARCHAR,
      ${Character.skillSlot4ColumnName} VARCHAR,
      ${Character.skillSlot5ColumnName} VARCHAR
		);
	''';

  final String id;
  final String name;
  final CharacterClass characterClass;
  final int level;
  final int gold;
  final int currentExp;
  final int currentHealth;
  final int currentMana;
  final int actionPoints;
  final CharacterSkills? skillSlot1;
  final CharacterSkills? skillSlot2;
  final CharacterSkills? skillSlot3;
  final CharacterSkills? skillSlot4;
  final CharacterSkills? skillSlot5;

  const Character({
    required this.id,
    required this.name,
    required this.characterClass,
    required this.level,
    required this.gold,
    required this.currentExp,
    required this.currentHealth,
    required this.currentMana,
    required this.actionPoints,
    this.skillSlot1,
    this.skillSlot2,
    this.skillSlot3,
    this.skillSlot4,
    this.skillSlot5,
  });

  int get maxHealth {
    return (level * 10) + characterClass.baseMaxHealth;
  }

  int get maxMana {
    return (level * 10) + 10;
  }

  Map<String, Object?> toMap() {
    return {
      Character.idColumnName: id,
      Character.nameColumnName: name,
      Character.characterClassColumnName: characterClass.index,
      Character.levelColumnName: level,
      Character.goldColumnName: gold,
      Character.currentExpColumnName: currentExp,
      Character.currentHealthColumnName: currentHealth,
      Character.currentManaColumnName: currentMana,
      Character.actionPointsColumnName: actionPoints,
      Character.skillSlot1ColumnName: skillSlot1?.id,
      Character.skillSlot2ColumnName: skillSlot2?.id,
      Character.skillSlot3ColumnName: skillSlot3?.id,
      Character.skillSlot4ColumnName: skillSlot4?.id,
      Character.skillSlot5ColumnName: skillSlot5?.id,
    };
  }

  @override
  String toString() {
    return 'Character {id: $id, name: $name, characterClass: $characterClass, level: $level, gold: $gold, currentExp: $currentExp, currentHealth: $currentHealth, currentMana: $currentMana, actionPoints: $actionPoints, skillSlot1: $skillSlot1, skillSlot2: $skillSlot2, skillSlot3: $skillSlot3, skillSlot4: $skillSlot4, skillSlot5: $skillSlot5}';
  }

  Character copyWith({
    String? name,
    CharacterClass? characterClass,
    int? level,
    int? gold,
    int? currentExp,
    int? currentHealth,
    int? currentMana,
    int? actionPoints,
    CharacterSkills? skillSlot1,
    CharacterSkills? skillSlot2,
    CharacterSkills? skillSlot3,
    CharacterSkills? skillSlot4,
    CharacterSkills? skillSlot5,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      characterClass: characterClass ?? this.characterClass,
      level: level ?? this.level,
      gold: gold ?? this.gold,
      currentExp: currentExp ?? this.currentExp,
      currentHealth: currentHealth ?? this.currentHealth,
      currentMana: currentMana ?? this.currentMana,
      actionPoints: actionPoints ?? this.actionPoints,
      skillSlot1: skillSlot1 ?? this.skillSlot1,
      skillSlot2: skillSlot2 ?? this.skillSlot2,
      skillSlot3: skillSlot3 ?? this.skillSlot3,
      skillSlot4: skillSlot4 ?? this.skillSlot4,
      skillSlot5: skillSlot5 ?? this.skillSlot5,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        characterClass,
        level,
        gold,
        currentExp,
        currentHealth,
        currentMana,
        actionPoints,
        skillSlot1,
        skillSlot2,
        skillSlot3,
        skillSlot4,
        skillSlot5
      ];
}
