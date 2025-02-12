import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/quest.dart';
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
    return _getCharacterFromMap(characterMaps[0]);
  }

  // GET by id
  Future<Character> getCharacterById(String id) async {
    final characterMaps = await db.query(
      Character.characterTableName,
      where: '${Character.idColumnName} = ?',
      whereArgs: [id],
      limit: 1,
    );
    final character = _getCharacterFromMap(characterMaps[0]);
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
    final character = getCharacterById(updateCharacter.id);
    return character;
  }

  // TODO temporary
  Future<void> printCharacters() async {
    final characterMaps = await db.query(Character.characterTableName);
    print(characterMaps);
  }

  // TODO temporary
  Future<void> printQuests() async {
    final questMaps = await db.query(Quest.questTableName);
    print(questMaps);
  }

  Character _getCharacterFromMap(Map<String, Object?> map) {
    final character = Character(
      id: map[Character.idColumnName] as String,
      name: map[Character.nameColumnName] as String,
      level: map[Character.levelColumnName] as int,
      currentExp: map[Character.currentExpColumnName] as int,
      currentHealth: map[Character.currentHealthColumnName] as int,
      maxHealth: map[Character.maxHealthColumnName] as int,
      currentMana: map[Character.currentManaColumnName] as int,
      maxMana: map[Character.maxManaColumnName] as int,
      attacksRemaining: map[Character.attacksRemainingColumnName] as int,
    );
    return character;
  }
}
