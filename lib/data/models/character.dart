import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character_skill.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/helpers/constants.dart';
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
  static const actionPointsColumnName = 'actionPoints';
  static const equippedWeaponColumnName = 'equippedWeapon';
  static const equippedHelmetColumnName = 'equippedHelmet';
  static const equippedChestplateColumnName = 'equippedChestplate';
  static const equippedGlovesColumnName = 'equippedGloves';
  static const equippedBootsColumnName = 'equippedBoots';
  static const equippedAmuletColumnName = 'equippedAmulet';
  static const equippedRing1ColumnName = 'equippedRing1';
  static const equippedRing2ColumnName = 'equippedRing2';
  static const skillSlot1ColumnName = 'skillSlot1';
  static const skillSlot2ColumnName = 'skillSlot2';
  static const skillSlot3ColumnName = 'skillSlot3';
  static const skillSlot4ColumnName = 'skillSlot4';
  static const skillSlot5ColumnName = 'skillSlot5';
  static const dailyApEarnedColumnName = 'dailyApEarned';
  static const dailyApEarnedDateColumnName = 'dailyApEarnedDate';
  static const themeIdColumnName = 'themeId';
  static const combatStatusCardExpandedColumnName = 'combatStatusCardExpanded';
  static const skillPointsColumnName = 'skillPoints';

  static const createTableSQL = '''
		CREATE TABLE ${Character.characterTableName}(
			${Character.idColumnName} VARCHAR PRIMARY KEY,
			${Character.nameColumnName} VARCHAR NOT NULL,
			${Character.characterClassColumnName} INTEGER NOT NULL,
			${Character.levelColumnName} INTEGER NOT NULL,
			${Character.goldColumnName} INTEGER NOT NULL,
			${Character.currentExpColumnName} INTEGER NOT NULL,
			${Character.currentHealthColumnName} INTEGER NOT NULL,
			${Character.actionPointsColumnName} INTEGER NOT NULL,
      ${Character.equippedWeaponColumnName} VARCHAR,
      ${Character.equippedHelmetColumnName} VARCHAR,
      ${Character.equippedChestplateColumnName} VARCHAR,
      ${Character.equippedGlovesColumnName} VARCHAR,
      ${Character.equippedBootsColumnName} VARCHAR,
      ${Character.equippedAmuletColumnName} VARCHAR,
      ${Character.equippedRing1ColumnName} VARCHAR,
      ${Character.equippedRing2ColumnName} VARCHAR,
      ${Character.skillSlot1ColumnName} VARCHAR,
      ${Character.skillSlot2ColumnName} VARCHAR,
      ${Character.skillSlot3ColumnName} VARCHAR,
      ${Character.skillSlot4ColumnName} VARCHAR,
      ${Character.skillSlot5ColumnName} VARCHAR,
      ${Character.dailyApEarnedColumnName} INTEGER DEFAULT 0,
      ${Character.dailyApEarnedDateColumnName} INTEGER,
      ${Character.themeIdColumnName} TEXT NOT NULL DEFAULT '$DEFAULT_THEME_ID',
      ${Character.combatStatusCardExpandedColumnName} BOOLEAN NOT NULL DEFAULT 1,
      ${Character.skillPointsColumnName} INTEGER NOT NULL DEFAULT 0
		);
	''';

  final String id;
  final String name;
  final CharacterClass characterClass;
  final int level;
  final int gold;
  final int currentExp;
  final int currentHealth;
  final int actionPoints;
  final Equipment? equippedWeapon;
  final Equipment? equippedHelmet;
  final Equipment? equippedChestplate;
  final Equipment? equippedGloves;
  final Equipment? equippedBoots;
  final Equipment? equippedAmulet;
  final Equipment? equippedRing1;
  final Equipment? equippedRing2;
  final List<CharacterSkill> skills;
  final CharacterSkill? activeSkillSlot1;
  final CharacterSkill? activeSkillSlot2;
  final CharacterSkill? activeSkillSlot3;
  final CharacterSkill? activeSkillSlot4;
  final CharacterSkill? activeSkillSlot5;
  final int dailyApEarned;
  final DateTime? dailyApEarnedDate;
  final String themeId;
  final bool combatStatusCardExpanded;
  final int skillPoints;

  const Character({
    required this.id,
    required this.name,
    required this.characterClass,
    required this.level,
    required this.gold,
    required this.currentExp,
    required this.currentHealth,
    required this.actionPoints,
    this.equippedWeapon,
    this.equippedHelmet,
    this.equippedChestplate,
    this.equippedGloves,
    this.equippedBoots,
    this.equippedAmulet,
    this.equippedRing1,
    this.equippedRing2,
    this.skills = const [],
    this.activeSkillSlot1,
    this.activeSkillSlot2,
    this.activeSkillSlot3,
    this.activeSkillSlot4,
    this.activeSkillSlot5,
    this.dailyApEarned = 0,
    this.dailyApEarnedDate,
    this.themeId = DEFAULT_THEME_ID,
    this.combatStatusCardExpanded = true,
    this.skillPoints = 0,
  });

  List<Equipment> get equippedEquipmentList => [
        if (equippedWeapon != null) equippedWeapon!,
        if (equippedHelmet != null) equippedHelmet!,
        if (equippedChestplate != null) equippedChestplate!,
        if (equippedGloves != null) equippedGloves!,
        if (equippedBoots != null) equippedBoots!,
        if (equippedAmulet != null) equippedAmulet!,
        if (equippedRing1 != null) equippedRing1!,
        if (equippedRing2 != null) equippedRing2!,
      ];

  Equipment? equippedForSlot(EquipmentSlot slot) {
    switch (slot) {
      case EquipmentSlot.weapon:
        return equippedWeapon;
      case EquipmentSlot.head:
        return equippedHelmet;
      case EquipmentSlot.body:
        return equippedChestplate;
      case EquipmentSlot.hands:
        return equippedGloves;
      case EquipmentSlot.feet:
        return equippedBoots;
      case EquipmentSlot.neck:
        return equippedAmulet;
      case EquipmentSlot.ring:
        return equippedRing1;
    }
  }

  Character copyWithEquippedForSlot(EquipmentSlot slot, Equipment equipment) {
    switch (slot) {
      case EquipmentSlot.weapon:
        return copyWith(equippedWeapon: equipment);
      case EquipmentSlot.head:
        return copyWith(equippedHelmet: equipment);
      case EquipmentSlot.body:
        return copyWith(equippedChestplate: equipment);
      case EquipmentSlot.hands:
        return copyWith(equippedGloves: equipment);
      case EquipmentSlot.feet:
        return copyWith(equippedBoots: equipment);
      case EquipmentSlot.neck:
        return copyWith(equippedAmulet: equipment);
      case EquipmentSlot.ring:
        return copyWith(equippedRing1: equipment);
    }
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
      Character.actionPointsColumnName: actionPoints,
      Character.equippedWeaponColumnName: equippedWeapon?.id,
      Character.equippedHelmetColumnName: equippedHelmet?.id,
      Character.equippedChestplateColumnName: equippedChestplate?.id,
      Character.equippedGlovesColumnName: equippedGloves?.id,
      Character.equippedBootsColumnName: equippedBoots?.id,
      Character.equippedAmuletColumnName: equippedAmulet?.id,
      Character.equippedRing1ColumnName: equippedRing1?.id,
      Character.equippedRing2ColumnName: equippedRing2?.id,
      Character.skillSlot1ColumnName: activeSkillSlot1?.id,
      Character.skillSlot2ColumnName: activeSkillSlot2?.id,
      Character.skillSlot3ColumnName: activeSkillSlot3?.id,
      Character.skillSlot4ColumnName: activeSkillSlot4?.id,
      Character.skillSlot5ColumnName: activeSkillSlot5?.id,
      Character.dailyApEarnedColumnName: dailyApEarned,
      Character.dailyApEarnedDateColumnName:
          dailyApEarnedDate?.millisecondsSinceEpoch,
      Character.themeIdColumnName: themeId,
      Character.combatStatusCardExpandedColumnName:
          combatStatusCardExpanded ? 1 : 0,
      Character.skillPointsColumnName: skillPoints,
    };
  }

  @override
  String toString() {
    return 'Character {id: $id, name: $name, characterClass: $characterClass, level: $level, gold: $gold, currentExp: $currentExp, currentHealth: $currentHealth, actionPoints: $actionPoints, equippedWeapon: $equippedWeapon, equippedHelmet: $equippedHelmet, equippedChestplate: $equippedChestplate, equippedGloves: $equippedGloves, equippedBoots: $equippedBoots, equippedAmulet: $equippedAmulet, equippedRing1: $equippedRing1, equippedRing2: $equippedRing2, skills: $skills, activeSkillSlot1: $activeSkillSlot1, activeSkillSlot2: $activeSkillSlot2, activeSkillSlot3: $activeSkillSlot3, activeSkillSlot4: $activeSkillSlot4, activeSkillSlot5: $activeSkillSlot5}';
  }

  Character copyWith({
    String? name,
    CharacterClass? characterClass,
    int? level,
    int? gold,
    int? currentExp,
    int? currentHealth,
    int? actionPoints,
    Equipment? equippedWeapon,
    Equipment? equippedHelmet,
    Equipment? equippedChestplate,
    Equipment? equippedGloves,
    Equipment? equippedBoots,
    Equipment? equippedAmulet,
    Equipment? equippedRing1,
    Equipment? equippedRing2,
    List<CharacterSkill>? skills,
    CharacterSkill? activeSkillSlot1,
    CharacterSkill? activeSkillSlot2,
    CharacterSkill? activeSkillSlot3,
    CharacterSkill? activeSkillSlot4,
    CharacterSkill? activeSkillSlot5,
    int? dailyApEarned,
    DateTime? dailyApEarnedDate,
    String? themeId,
    bool? combatStatusCardExpanded,
    int? skillPoints,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      characterClass: characterClass ?? this.characterClass,
      level: level ?? this.level,
      gold: gold ?? this.gold,
      currentExp: currentExp ?? this.currentExp,
      currentHealth: currentHealth ?? this.currentHealth,
      actionPoints: actionPoints ?? this.actionPoints,
      equippedWeapon: equippedWeapon ?? this.equippedWeapon,
      equippedHelmet: equippedHelmet ?? this.equippedHelmet,
      equippedChestplate: equippedChestplate ?? this.equippedChestplate,
      equippedGloves: equippedGloves ?? this.equippedGloves,
      equippedBoots: equippedBoots ?? this.equippedBoots,
      equippedAmulet: equippedAmulet ?? this.equippedAmulet,
      equippedRing1: equippedRing1 ?? this.equippedRing1,
      equippedRing2: equippedRing2 ?? this.equippedRing2,
      skills: skills ?? this.skills,
      activeSkillSlot1: activeSkillSlot1 ?? this.activeSkillSlot1,
      activeSkillSlot2: activeSkillSlot2 ?? this.activeSkillSlot2,
      activeSkillSlot3: activeSkillSlot3 ?? this.activeSkillSlot3,
      activeSkillSlot4: activeSkillSlot4 ?? this.activeSkillSlot4,
      activeSkillSlot5: activeSkillSlot5 ?? this.activeSkillSlot5,
      dailyApEarned: dailyApEarned ?? this.dailyApEarned,
      dailyApEarnedDate: dailyApEarnedDate ?? this.dailyApEarnedDate,
      themeId: themeId ?? this.themeId,
      combatStatusCardExpanded:
          combatStatusCardExpanded ?? this.combatStatusCardExpanded,
      skillPoints: skillPoints ?? this.skillPoints,
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
        actionPoints,
        equippedWeapon,
        equippedHelmet,
        equippedChestplate,
        equippedGloves,
        equippedBoots,
        equippedAmulet,
        equippedRing1,
        equippedRing2,
        skills,
        activeSkillSlot1,
        activeSkillSlot2,
        activeSkillSlot3,
        activeSkillSlot4,
        activeSkillSlot5,
        dailyApEarned,
        dailyApEarnedDate,
        themeId,
        combatStatusCardExpanded,
        skillPoints,
      ];
}
