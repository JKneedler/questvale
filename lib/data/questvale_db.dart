import 'package:path/path.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/encounter_reward.dart';
import 'package:questvale/data/models/enemy_attack_data.dart';
import 'package:questvale/data/models/enemy_data.dart';
import 'package:questvale/data/models/enemy_drop_data.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/equipment_encounter_reward.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/models/quest_zone.dart';
import 'package:questvale/data/models/stat_modifier.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/todo_tag.dart';
import 'package:questvale/data/models/todo_reminder.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/seed/enemy_data_seed.dart';
import 'package:questvale/data/seed/quest_zones_seed.dart';
import 'package:questvale/helpers/shared_enums.dart';
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
          characterClass: CharacterClass.mage,
          level: 10,
          gold: 1997,
          currentExp: 0,
          currentHealth: 20,
          currentMana: 10,
          attacksRemaining: 10,
        ),
      );

      await db.execute(QuestZone.createTableSQL);
      await seedQuestZones(db);
      await db.execute(Quest.createTableSQL);
      await db.execute(Encounter.createTableSQL);
      await db.execute(EncounterReward.createTableSQL);

      await db.execute(Equipment.createTableSQL);
      await db.execute(EquipmentEncounterReward.createTableSQL);
      await db.execute(StatModifier.createTableSQL);

      await db.execute(EnemyData.createTableSQL);
      await db.execute(EnemyAttackData.createTableSQL);
      await db.execute(EnemyDropData.createTableSQL);
      await seedEnemyData(db);
      await db.execute(Enemy.createTableSQL);
    }, version: 1);
  }
}
