import 'package:path/path.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/inventory_equipment.dart';
import 'package:questvale/data/models/inventory.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/equipment_modifier.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/models/quest_room.dart';
import 'package:questvale/data/models/character_skill.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/todo_tag.dart';
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
      await db.execute(CharacterTag.createTableSQL);
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
      characterRepo.insertCharacter(
        Character(
          id: Uuid().v4(),
          name: 'Doug',
          characterClass: CharacterClass.warrior,
          level: 20,
          currentExp: 0,
          inventory: Inventory(id: Uuid().v4(), gold: 0, equipments: []),
          currentHealth: 20,
          currentMana: 10,
          attacksRemaining: 10,
          skills: [],
        ),
      );
    }, version: 1);
  }
}
