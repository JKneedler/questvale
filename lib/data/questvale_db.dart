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
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/data/models/stat_modifier.dart';
import 'package:questvale/data/models/status_effect_instance.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/todo_tag.dart';
import 'package:questvale/data/models/todo_reminder.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/models/mage_motes.dart';
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
      await db.execute(MageMotes.createTableSQL);
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
        skillId: 'mage-1-firebolt',
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
          actionPoints: 10,
          skills: [],
          activeSkillSlot1: activeSkillSlot1,
          activeSkillSlot2: activeSkillSlot2,
        ),
      );
      await db.insert(CharacterStats.characterStatsTableName,
          CharacterStats(characterId: characterId).toMap());
      await db.insert(MageMotes.mageMotesTableName,
          MageMotes(characterId: characterId).toMap());
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
      await db.execute(ScheduledTimer.createTableSQL);
      await db.execute(StatusEffectInstance.createTableSQL);
    }, onUpgrade: (db, oldVersion, newVersion) async {
      // TodoTag/CharacterTag were never added to a version-gated migration
      // block when the tags feature shipped, so any install that upgraded
      // through that point instead of a fresh install never got these
      // tables — every tag-related insert then silently failed. Run
      // unconditionally (IF NOT EXISTS) on every upgrade rather than
      // guessing which version boundary they should have belonged to.
      await db.execute(TodoTag.createTableSQL
          .replaceFirst('CREATE TABLE', 'CREATE TABLE IF NOT EXISTS'));
      await db.execute(CharacterTag.createTableSQL
          .replaceFirst('CREATE TABLE', 'CREATE TABLE IF NOT EXISTS'));

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
      if (oldVersion < 10) {
        // Tags were simplified to name-only; colorIndex/iconIndex only
        // exist on installs that had the table pre-simplification (a
        // fresh IF NOT EXISTS create above already omits them).
        final columns = await db.rawQuery(
            'PRAGMA table_info(${CharacterTag.characterTagTableName})');
        final hasColorIndex = columns.any((c) => c['name'] == 'colorIndex');
        if (hasColorIndex) {
          await db.execute(
              'ALTER TABLE ${CharacterTag.characterTagTableName} DROP COLUMN colorIndex');
          await db.execute(
              'ALTER TABLE ${CharacterTag.characterTagTableName} DROP COLUMN iconIndex');
        }
      }
      if (oldVersion < 11) {
        await db.execute(
            'ALTER TABLE ${Character.characterTableName} ADD COLUMN ${Character.combatStatusCardExpandedColumnName} BOOLEAN NOT NULL DEFAULT 1');
      }
      if (oldVersion < 12) {
        await db.execute(ScheduledTimer.createTableSQL);
      }
      if (oldVersion < 13) {
        // Mage's Mana -> Motes rework: new per-class resource table (see
        // MageMotes doc comment), plus dropping the now-retired Mana
        // columns off Character. Every install below version 13 always had
        // currentMana (it's been NOT NULL since the very first schema), so
        // this drop needs no existence check unlike some earlier ones.
        await db.execute(MageMotes.createTableSQL);
        final characterIds = await db.query(Character.characterTableName,
            columns: [Character.idColumnName]);
        for (final row in characterIds) {
          await db.insert(
              MageMotes.mageMotesTableName,
              MageMotes(characterId: row[Character.idColumnName] as String)
                  .toMap());
        }
        await db.execute(
            'ALTER TABLE ${Character.characterTableName} DROP COLUMN currentMana');
      }
      if (oldVersion < 14) {
        // Skill System Foundations subtask 3: Burn/Slow's runtime model —
        // see StatusEffectInstance's doc comment. New table only, no
        // backfill needed (no prior version ever had status effects).
        await db.execute(StatusEffectInstance.createTableSQL);
      }
    }, version: 14);
  }
}
