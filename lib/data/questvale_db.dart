import 'package:path/path.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/todo_tag.dart';
import 'package:questvale/data/models/todo_reminder.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class QuestvaleDB {
  static Future<Database> initializeDB() async {
    return await openDatabase(join(await getDatabasesPath(), 'questvaledb'),
        onCreate: (db, version) async {
      await db.execute(Todo.createTableSQL);
      await db.execute(TodoTag.createTableSQL);
      await db.execute(TodoReminder.createTableSQL);
      await db.execute(CharacterTag.createTableSQL);
      await db.execute(Character.createTableSQL);
      final CharacterRepository characterRepo = CharacterRepository(db: db);
      characterRepo.insertCharacter(
        Character(
          id: Uuid().v4(),
          name: 'Doug',
          characterClass: CharacterClass.warrior,
          level: 20,
          currentExp: 0,
          currentHealth: 20,
          currentMana: 10,
          attacksRemaining: 10,
        ),
      );
    }, version: 1);
  }
}
