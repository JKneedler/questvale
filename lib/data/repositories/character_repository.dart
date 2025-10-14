import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:sqflite/sqflite.dart';

class CharacterRepository {
  final Database db;

  CharacterRepository({required this.db});

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
          colorIndex: tagMap[CharacterTag.colorIndexColumnName] as int,
          iconIndex: tagMap[CharacterTag.iconIndexColumnName] as int,
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
    print(characterMaps);
  }

  Future<Character> _getCharacterFromMap(Map<String, Object?> map) async {
    final character = Character(
      id: map[Character.idColumnName] as String,
      name: map[Character.nameColumnName] as String,
      characterClass:
          CharacterClass.values[map[Character.characterClassColumnName] as int],
      level: map[Character.levelColumnName] as int,
      currentExp: map[Character.currentExpColumnName] as int,
      currentHealth: map[Character.currentHealthColumnName] as int,
      currentMana: map[Character.currentManaColumnName] as int,
      attacksRemaining: map[Character.attacksRemainingColumnName] as int,
    );
    return character;
  }
}
