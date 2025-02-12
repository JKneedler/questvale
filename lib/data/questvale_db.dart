import 'package:path/path.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/checklist_item.dart';
import 'package:questvale/data/models/combatant.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/models/quest_room.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/task.dart';
import 'package:questvale/data/models/task_tag.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class QuestvaleDB {
  static Future<Database> initializeDB() async {
    return await openDatabase(join(await getDatabasesPath(), 'questvaledb'),
        onCreate: (db, version) async {
      await db.execute(Task.createTableSQL);
      print('Created Task table');
      await db.execute(TaskTag.createTableSQL);
      print('Created TaskTag table');
      await db.execute(Tag.createTableSQL);
      print('Created Tag table');
      await db.execute(ChecklistItem.createTableSQL);
      print('Created ChecklistItem table');
      await db.execute(Character.createTableSQL);
      print('Created Characters table');
      await db.execute(Quest.createTableSQL);
      print('Created Quests table');
      await db.execute(QuestRoom.createTableSQL);
      print('Created QuestRooms table');
      await db.execute(Combatant.createTableSQL);
      print('Created Combatants table');
      await db.insert(
        'Characters',
        Character(
          id: Uuid().v1(),
          name: 'Kelsier',
          level: 1,
          currentExp: 0,
          currentHealth: 20,
          maxHealth: 20,
          currentMana: 10,
          maxMana: 10,
          attacksRemaining: 10,
        ).toMap(),
      );

      await db.insert(
        'Tags',
        Tag(
          id: Uuid().v1(),
          name: 'Work',
        ).toMap(),
      );
      print('Inserted initial Tag');
    }, version: 1);
  }
}
