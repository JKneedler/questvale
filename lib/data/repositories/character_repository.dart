import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_skill.dart';
import 'package:questvale/data/models/character_stats.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:sqflite/sqflite.dart';

class CharacterRepository {
  final Database db;

  late EquipmentRepository equipmentRepository;

  CharacterRepository({required this.db}) {
    equipmentRepository = EquipmentRepository(db: db);
  }

  // GET the one existing character -- temporary
  Future<Character> getSingleCharacter() async {
    final characterMaps = await db.query(
      Character.characterTableName,
      limit: 1,
    );
    final character = await _getCharacterFromMap(characterMaps[0]);
    return character;
  }

  // GET by id
  Future<Character> getCharacterById(String id) async {
    final characterMaps = await db.query(
      Character.characterTableName,
      where: '${Character.idColumnName} = ?',
      whereArgs: [id],
      limit: 1,
    );
    final character = await _getCharacterFromMap(characterMaps[0]);
    return character;
  }

  // UPDATE by character
  Future<Character> updateCharacter(Character updateCharacter) async {
    await db.update(
      Character.characterTableName,
      updateCharacter.toMap(),
      where: '${Character.idColumnName} = ?',
      whereArgs: [updateCharacter.id],
    );
    final character = await getCharacterById(updateCharacter.id);
    return character;
  }

  // INSERT character
  Future<void> insertCharacter(Character insertCharacter) async {
    await db.insert(
      Character.characterTableName,
      insertCharacter.toMap(),
    );
  }

  // CHARACTER TAGS METHODS
  Future<List<CharacterTag>> getCharacterTags(String characterId) async {
    final tagMaps = await db.query(
      CharacterTag.characterTagTableName,
      where: '${CharacterTag.characterIdColumnName} = ?',
      whereArgs: [characterId],
    );

    return [
      for (final tagMap in tagMaps)
        CharacterTag(
          id: tagMap[CharacterTag.idColumnName] as String,
          characterId: tagMap[CharacterTag.characterIdColumnName] as String,
          name: tagMap[CharacterTag.nameColumnName] as String,
        ),
    ];
  }

  Future<void> createCharacterTag(CharacterTag tag) async {
    await db.insert(
      CharacterTag.characterTagTableName,
      tag.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCharacterTag(CharacterTag tag) async {
    await db.update(
      CharacterTag.characterTagTableName,
      tag.toMap(),
      where: '${CharacterTag.idColumnName} = ?',
      whereArgs: [tag.id],
    );
  }

  Future<void> deleteCharacterTag(CharacterTag tag) async {
    await db.delete(
      CharacterTag.characterTagTableName,
      where: '${CharacterTag.idColumnName} = ?',
      whereArgs: [tag.id],
    );
  }

  Future<void> printCharacters() async {
    final characterMaps = await db.query(Character.characterTableName);
  }

  Future<Character> _getCharacterFromMap(Map<String, Object?> map) async {
    final skills =
        await getSkillsByCharacterId(map[Character.idColumnName] as String);
    final skillSlot1 = map[Character.skillSlot1ColumnName] as String?;
    final activeSkillSlot1 =
        skillSlot1 != null ? await getSkillById(skillSlot1) : null;
    final skillSlot2 = map[Character.skillSlot2ColumnName] as String?;
    final activeSkillSlot2 =
        skillSlot2 != null ? await getSkillById(skillSlot2) : null;
    final skillSlot3 = map[Character.skillSlot3ColumnName] as String?;
    final activeSkillSlot3 =
        skillSlot3 != null ? await getSkillById(skillSlot3) : null;
    final skillSlot4 = map[Character.skillSlot4ColumnName] as String?;
    final activeSkillSlot4 =
        skillSlot4 != null ? await getSkillById(skillSlot4) : null;
    final skillSlot5 = map[Character.skillSlot5ColumnName] as String?;
    final activeSkillSlot5 =
        skillSlot5 != null ? await getSkillById(skillSlot5) : null;

    final equippedWeapon = map[Character.equippedWeaponColumnName] as String?;
    final weapon = equippedWeapon != null
        ? await equipmentRepository.getEquipmentById(equippedWeapon)
        : null;
    final equippedHelmet = map[Character.equippedHelmetColumnName] as String?;
    final helmet = equippedHelmet != null
        ? await equipmentRepository.getEquipmentById(equippedHelmet)
        : null;
    final equippedChestplate =
        map[Character.equippedChestplateColumnName] as String?;
    final chestplate = equippedChestplate != null
        ? await equipmentRepository.getEquipmentById(equippedChestplate)
        : null;
    final equippedGloves = map[Character.equippedGlovesColumnName] as String?;
    final gloves = equippedGloves != null
        ? await equipmentRepository.getEquipmentById(equippedGloves)
        : null;
    final equippedBoots = map[Character.equippedBootsColumnName] as String?;
    final boots = equippedBoots != null
        ? await equipmentRepository.getEquipmentById(equippedBoots)
        : null;
    final equippedAmulet = map[Character.equippedAmuletColumnName] as String?;
    final amulet = equippedAmulet != null
        ? await equipmentRepository.getEquipmentById(equippedAmulet)
        : null;
    final equippedRing1 = map[Character.equippedRing1ColumnName] as String?;
    final ring1 = equippedRing1 != null
        ? await equipmentRepository.getEquipmentById(equippedRing1)
        : null;
    final equippedRing2 = map[Character.equippedRing2ColumnName] as String?;
    final ring2 = equippedRing2 != null
        ? await equipmentRepository.getEquipmentById(equippedRing2)
        : null;

    final character = Character(
      id: map[Character.idColumnName] as String,
      name: map[Character.nameColumnName] as String,
      characterClass:
          CharacterClass.values[map[Character.characterClassColumnName] as int],
      level: map[Character.levelColumnName] as int,
      gold: map[Character.goldColumnName] as int,
      currentExp: map[Character.currentExpColumnName] as int,
      currentHealth: map[Character.currentHealthColumnName] as int,
      currentMana: map[Character.currentManaColumnName] as int,
      actionPoints: map[Character.actionPointsColumnName] as int,
      equippedWeapon: weapon,
      equippedHelmet: helmet,
      equippedChestplate: chestplate,
      equippedGloves: gloves,
      equippedBoots: boots,
      equippedAmulet: amulet,
      equippedRing1: ring1,
      equippedRing2: ring2,
      skills: skills,
      activeSkillSlot1: activeSkillSlot1,
      activeSkillSlot2: activeSkillSlot2,
      activeSkillSlot3: activeSkillSlot3,
      activeSkillSlot4: activeSkillSlot4,
      activeSkillSlot5: activeSkillSlot5,
      dailyApEarned: map[Character.dailyApEarnedColumnName] as int? ?? 0,
      dailyApEarnedDate: map[Character.dailyApEarnedDateColumnName] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map[Character.dailyApEarnedDateColumnName] as int)
          : null,
      themeId: map[Character.themeIdColumnName] as String? ?? DEFAULT_THEME_ID,
    );
    return character;
  }

  // CHARACTER STATS METHODS
  Future<CharacterStats> getCharacterStats(String characterId) async {
    final maps = await db.query(
      CharacterStats.characterStatsTableName,
      where: '${CharacterStats.characterIdColumnName} = ?',
      whereArgs: [characterId],
      limit: 1,
    );
    if (maps.isEmpty) {
      final stats = CharacterStats(characterId: characterId);
      await db.insert(CharacterStats.characterStatsTableName, stats.toMap());
      return stats;
    }
    final map = maps[0];
    return CharacterStats(
      characterId: map[CharacterStats.characterIdColumnName] as String,
      longestStreakAchieved:
          map[CharacterStats.longestStreakAchievedColumnName] as int? ?? 0,
      totalCompleted: map[CharacterStats.totalCompletedColumnName] as int? ?? 0,
    );
  }

  Future<void> updateCharacterStats(CharacterStats stats) async {
    await db.update(
      CharacterStats.characterStatsTableName,
      stats.toMap(),
      where: '${CharacterStats.characterIdColumnName} = ?',
      whereArgs: [stats.characterId],
    );
  }

  Future<void> insertCharacterSkill(CharacterSkill skill) async {
    await db.insert(CharacterSkill.characterSkillTableName, skill.toMap());
  }

  Future<List<CharacterSkill>> getSkillsByCharacterId(
      String characterId) async {
    final skillMaps = await db.query(
      CharacterSkill.characterSkillTableName,
      where: '${CharacterSkill.characterIdColumnName} = ?',
      whereArgs: [characterId],
    );
    return skillMaps.map((skillMap) => _getSkillFromMap(skillMap)).toList();
  }

  Future<CharacterSkill?> getSkillById(String? skillId) async {
    if (skillId == null) return null;

    final skillMap = await db.query(
      CharacterSkill.characterSkillTableName,
      where: '${CharacterSkill.idColumnName} = ?',
      whereArgs: [skillId],
      limit: 1,
    );

    return skillMap.isEmpty ? null : _getSkillFromMap(skillMap.first);
  }

  CharacterSkill _getSkillFromMap(Map<String, Object?> map) {
    return CharacterSkill(
      id: map[CharacterSkill.idColumnName] as String,
      characterId: map[CharacterSkill.characterIdColumnName] as String,
      skillId: map[CharacterSkill.skillIdColumnName] as String,
      level: map[CharacterSkill.levelColumnName] as int,
    );
  }
}
