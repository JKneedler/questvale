import 'package:questvale/data/models/character_skill.dart';
import 'package:sqflite/sqflite.dart';

class CharacterSkillRepository {
  final Database db;

  CharacterSkillRepository({required this.db});

  // GET by id
  Future<CharacterSkill> getById(String id) async {
    final skillMaps = await db.query(
      CharacterSkill.skillTableName,
      where: '${CharacterSkill.idColumnName} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return _getSkillFromMap(skillMaps[0]);
  }

  // GET by character id
  Future<List<CharacterSkill>> getByCharacterId(String characterId) async {
    final skillMaps = await db.query(
      CharacterSkill.skillTableName,
      where: '${CharacterSkill.characterColumnName} = ?',
      whereArgs: [characterId],
    );
    final skills = [for (final map in skillMaps) _getSkillFromMap(map)];
    return skills;
  }

  // INSERT
  Future<void> insertSkill(CharacterSkill insertSkill) async {
    await db.insert(CharacterSkill.skillTableName, insertSkill.toMap());
  }

  // UPDATE
  Future<void> updateSkill(CharacterSkill updateSkill) async {
    await db.update(
      CharacterSkill.skillTableName,
      updateSkill.toMap(),
      where: '${CharacterSkill.idColumnName} = ?',
      whereArgs: [updateSkill.id],
    );
  }

  // DELETE
  Future<void> deleteSkill(CharacterSkill deleteSkill) async {
    await db.delete(
      CharacterSkill.skillTableName,
      where: '${CharacterSkill.idColumnName} = ?',
      whereArgs: [deleteSkill.id],
    );
  }

  CharacterSkill _getSkillFromMap(Map<String, Object?> map) {
    return CharacterSkill(
      id: map[CharacterSkill.idColumnName] as String,
      characterId: map[CharacterSkill.characterColumnName] as String,
      type: SkillType.values[map[CharacterSkill.typeColumnName] as int],
      level: map[CharacterSkill.levelColumnName] as int,
    );
  }
}
