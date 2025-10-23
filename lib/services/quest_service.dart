import 'dart:math';

import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/encounter_reward.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/enemy_data.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/models/quest_summary.dart';
import 'package:questvale/data/models/quest_zone.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class QuestService {
  final Database db;

  QuestService({required this.db}) {
    questRepository = QuestRepository(db: db);
  }

  late QuestRepository questRepository;

  Future<bool> beginQuestGeneration(
      Character character, QuestZone questZone) async {
    final quest = generateQuest(character, questZone);
    try {
      await questRepository.insertQuest(quest);
      await questRepository.insertQuestSummary(
          QuestSummary(id: Uuid().v4(), questId: quest.id, xp: 0, gold: 0));
    } catch (e) {
      return false;
    }
    return true;
  }

  Quest generateQuest(Character character, QuestZone questZone) {
    final numFloors =
        Random().nextInt(questZone.maxFloors - questZone.minFloors + 1) +
            questZone.minFloors;
    final numEncountersCurFloor = Random().nextInt(
            questZone.maxEncountersPerFloor -
                questZone.minEncountersPerFloor +
                1) +
        questZone.minEncountersPerFloor;
    return Quest(
      id: Uuid().v4(),
      zone: questZone,
      characterId: character.id,
      numFloors: numFloors,
      numEncountersCurFloor: 2,
      curFloor: 1,
      curEncounterNum: 1,
      createdAt: DateTime.now(),
    );
  }

  Future<Encounter> generateEncounter(Quest quest, QuestZone questZone) async {
    final String encounterId = Uuid().v4();
    final List<EnemyData> enemyData = questZone.enemies;
    final enemyData1 = enemyData[Random().nextInt(enemyData.length)];
    final enemyData2 = enemyData[Random().nextInt(enemyData.length)];
    final enemyData3 = enemyData[Random().nextInt(enemyData.length)];
    final encounter = Encounter(
      id: encounterId,
      encounterType: EncounterType.genericCombat,
      questId: quest.id,
      enemies: [
        Enemy(
          id: Uuid().v4(),
          encounterId: encounterId,
          enemyData: enemyData1,
          currentHealth: enemyData1.health,
          position: 0,
        ),
        Enemy(
          id: Uuid().v4(),
          encounterId: encounterId,
          enemyData: enemyData2,
          currentHealth: enemyData2.health,
          position: 1,
        ),
        Enemy(
          id: Uuid().v4(),
          encounterId: encounterId,
          enemyData: enemyData3,
          currentHealth: enemyData3.health,
          position: 2,
        ),
      ],
      createdAt: DateTime.now(),
      // chestRarity: Rarity.common,
    );
    return encounter;
  }

  Future<EncounterReward> generateEncounterReward(Encounter encounter) async {
    final xp = encounter.encounterType.isCombatEncounter()
        ? Random().nextInt(100) + 1
        : 0;
    final gold = Random().nextInt(100) + 1;
    return EncounterReward(
      id: Uuid().v4(),
      encounterId: encounter.id,
      questId: encounter.questId,
      xp: xp,
      gold: gold,
      createdAt: DateTime.now(),
    );
  }
}
