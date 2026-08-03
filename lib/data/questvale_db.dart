import 'package:path/path.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_skill.dart';
import 'package:questvale/data/models/character_stats.dart';
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
import 'package:questvale/helpers/constants.dart';
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
      await db.execute(CharacterStats.createTableSQL);
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
      await db.insert(CharacterStats.characterStatsTableName,
          CharacterStats(characterId: characterId).toMap());
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
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute(
            'ALTER TABLE ${Todo.todoTableName} ADD COLUMN ${Todo.isHabitColumnName} BOOLEAN DEFAULT 0');
        await db.execute(
            'ALTER TABLE ${Todo.todoTableName} ADD COLUMN ${Todo.timeframeColumnName} INTEGER');
        await db.execute(
            'ALTER TABLE ${Todo.todoTableName} ADD COLUMN ${Todo.allowsMultipleCompletionsColumnName} BOOLEAN DEFAULT 0');
        await db.execute(
            'ALTER TABLE ${Todo.todoTableName} ADD COLUMN ${Todo.completionsInCurrentPeriodColumnName} INTEGER DEFAULT 0');
        await db.execute(
            'ALTER TABLE ${Todo.todoTableName} ADD COLUMN ${Todo.currentStreakColumnName} INTEGER DEFAULT 0');
        await db.execute(
            'ALTER TABLE ${Todo.todoTableName} ADD COLUMN ${Todo.currentPeriodStartColumnName} INTEGER');
      }
      if (oldVersion < 3) {
        await db.execute(
            'ALTER TABLE ${Character.characterTableName} ADD COLUMN ${Character.dailyApEarnedColumnName} INTEGER DEFAULT 0');
        await db.execute(
            'ALTER TABLE ${Character.characterTableName} ADD COLUMN ${Character.dailyApEarnedDateColumnName} INTEGER');
      }
      if (oldVersion < 4) {
        // Column was named apAwarded at the time; renamed to
        // completionAwarded in the version 6 migration below.
        await db.execute(
            'ALTER TABLE ${Todo.todoTableName} ADD COLUMN apAwarded BOOLEAN DEFAULT 0');
      }
      if (oldVersion < 5) {
        await db.execute(
            'ALTER TABLE ${TodoReminder.todoReminderTableName} ADD COLUMN ${TodoReminder.reminderTypeColumnName} INTEGER');
      }
      if (oldVersion < 6) {
        await db.execute(
            'ALTER TABLE ${Todo.todoTableName} RENAME COLUMN apAwarded TO ${Todo.completionAwardedColumnName}');
        // Columns were briefly on Characters directly; moved to their own
        // CharacterStats table in the version 7 migration below.
        await db.execute(
            'ALTER TABLE ${Character.characterTableName} ADD COLUMN longestStreakAchieved INTEGER DEFAULT 0');
        await db.execute(
            'ALTER TABLE ${Character.characterTableName} ADD COLUMN totalCompleted INTEGER DEFAULT 0');
      }
      if (oldVersion < 7) {
        await db.execute(CharacterStats.createTableSQL);
        // Backfill from Characters for anyone who already has those columns
        // (from the version 6 migration above); harmless no-op otherwise
        // since a fresh version-6 install never had them at all.
        final hasLegacyColumns = (await db
                .rawQuery('PRAGMA table_info(${Character.characterTableName})'))
            .any((column) => column['name'] == 'longestStreakAchieved');
        if (hasLegacyColumns) {
          await db.execute('''
            INSERT INTO ${CharacterStats.characterStatsTableName} (
              ${CharacterStats.characterIdColumnName},
              ${CharacterStats.longestStreakAchievedColumnName},
              ${CharacterStats.totalCompletedColumnName}
            )
            SELECT ${Character.idColumnName}, longestStreakAchieved, totalCompleted
            FROM ${Character.characterTableName}
          ''');
          await db.execute(
              'ALTER TABLE ${Character.characterTableName} DROP COLUMN longestStreakAchieved');
          await db.execute(
              'ALTER TABLE ${Character.characterTableName} DROP COLUMN totalCompleted');
        }
      }
      if (oldVersion < 8) {
        await db.execute(
            'ALTER TABLE ${Character.characterTableName} ADD COLUMN ${Character.themeIdColumnName} TEXT NOT NULL DEFAULT \'$DEFAULT_THEME_ID\'');
      }
      if (oldVersion < 9) {
        await db.execute(
            'ALTER TABLE ${Todo.todoTableName} ADD COLUMN ${Todo.repeatIntervalColumnName} INTEGER DEFAULT 1');
        await db.execute(
            'ALTER TABLE ${Todo.todoTableName} ADD COLUMN ${Todo.repeatWeekdaysColumnName} INTEGER DEFAULT 0');
        await db.execute(
            'ALTER TABLE ${Todo.todoTableName} ADD COLUMN ${Todo.monthlyRepeatModeColumnName} INTEGER DEFAULT 0');
      }
    }, version: 9);
  }
}
