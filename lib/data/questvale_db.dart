import 'package:path/path.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_skill.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/encounter_reward.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/equipment_encounter_reward.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/models/stat_modifier.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/todo_tag.dart';
import 'package:questvale/data/models/todo_reminder.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/repositories/character_repository.dart';
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
      final characterId = Uuid().v4();
      final activeSkillSlot1 = CharacterSkill(
        id: Uuid().v4(),
        characterId: characterId,
        skillId: 'mage-1-arcane_bolt',
        level: 1,
      );
      final activeSkillSlot2 = CharacterSkill(
        id: Uuid().v4(),
        characterId: characterId,
        skillId: 'mage-1-elemental_surge',
        level: 1,
      );
      characterRepo.insertCharacter(
        Character(
          id: characterId,
          name: 'Doug',
          characterClass: CharacterClass.mage,
          level: 10,
          gold: 1997,
          currentExp: 0,
          currentHealth: 20,
          currentMana: 10,
          actionPoints: 10,
          skills: [],
          activeSkillSlot1: activeSkillSlot1,
          activeSkillSlot2: activeSkillSlot2,
        ),
      );
      await db.execute(CharacterSkill.createTableSQL);
      characterRepo.insertCharacterSkill(
        activeSkillSlot1,
      );
      characterRepo.insertCharacterSkill(
        activeSkillSlot2,
      );
      await db.execute(Quest.createTableSQL);
      await db.execute(Encounter.createTableSQL);
      await db.execute(EncounterReward.createTableSQL);

      await db.execute(Equipment.createTableSQL);
      await db.execute(EquipmentEncounterReward.createTableSQL);
      await db.execute(StatModifier.createTableSQL);

      await db.execute(Enemy.createTableSQL);
    }, version: 1);
  }
}
