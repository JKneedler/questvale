import 'package:path/path.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/inventory_equipment.dart';
import 'package:questvale/data/models/inventory.dart';
import 'package:questvale/data/models/checklist_item.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/equipment_modifier.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/models/quest_room.dart';
import 'package:questvale/data/models/character_skill.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/task.dart';
import 'package:questvale/data/models/task_tag.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class QuestvaleDB {
  static Future<Database> initializeDB() async {
    return await openDatabase(join(await getDatabasesPath(), 'questvaledb'),
        onCreate: (db, version) async {
      await db.execute(Task.createTableSQL);
      await db.execute(TaskTag.createTableSQL);
      await db.execute(Tag.createTableSQL);
      await db.execute(ChecklistItem.createTableSQL);
      await db.execute(Character.createTableSQL);
      await db.execute(Quest.createTableSQL);
      await db.execute(QuestRoom.createTableSQL);
      await db.execute(Enemy.createTableSQL);
      await db.execute(Equipment.createTableSQL);
      await db.execute(InventoryEquipment.createTableSQL);
      await db.execute(EquipmentModifier.createTableSQL);
      await db.execute(Inventory.createTableSQL);
      await db.execute(CharacterSkill.createTableSQL);
      final CharacterRepository characterRepo = CharacterRepository(db: db);
      characterRepo.insertCharacter(Character(
          id: Uuid().v1(),
          name: 'Doug',
          characterClass: CharacterClass.warrior,
          level: 20,
          currentExp: 0,
          inventory: Inventory(id: Uuid().v1(), gold: 0, equipments: []),
          currentHealth: 20,
          currentMana: 10,
          attacksRemaining: 10,
          skills: []));

      await db.insert(
        'Tags',
        Tag(
          id: Uuid().v1(),
          name: 'Work',
        ).toMap(),
      );
      await db.insert(
        'Tags',
        Tag(
          id: Uuid().v1(),
          name: 'Health',
        ).toMap(),
      );
      await db.insert(
        'Tags',
        Tag(
          id: Uuid().v1(),
          name: 'Education',
        ).toMap(),
      );
      await db.insert(
        'Tags',
        Tag(
          id: Uuid().v1(),
          name: 'Finance',
        ).toMap(),
      );
    }, version: 1);
  }
}
