import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/encounter_reward.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/equipment_encounter_reward.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class EncounterRepository {
  final Database db;

  late EnemyRepository enemyRepository;
  late EquipmentRepository equipmentRepository;

  EncounterRepository({required this.db}) {
    enemyRepository = EnemyRepository(db: db);
    equipmentRepository = EquipmentRepository(db: db);
  }

  /*

  --------------------------- Encounter ---------------------------------

  */

  // GET ENCOUNTER BY ID
  Future<Encounter> getEncounterById(String encounterId) async {
    final result = await db.query(Encounter.encounterTableName,
        where: '${Encounter.idColumnName} = ?', whereArgs: [encounterId]);
    if (result.isEmpty) {
      throw Exception('Encounter $encounterId not found');
    }

    final encounter = await _getEncounterFromMap(result[0]);
    return encounter;
  }

  // GET ENCOUNTER BY QUEST ID
  Future<Encounter?> getEncounterByQuestId(String questId) async {
    final result = await db.query(Encounter.encounterTableName,
        where: '${Encounter.questIdColumnName} = ?', whereArgs: [questId]);
    if (result.length > 1) {
      throw Exception('Multiple encounters found for quest $questId');
    } else if (result.isEmpty) {
      return null;
    }

    final encounter = await _getEncounterFromMap(result[0]);
    return encounter;
  }

  // GET NUMBER OF TOTAL ENCOUNTERS
  Future<int> getEncountersNum() async {
    final result = await db.query(Encounter.encounterTableName);
    print(result);
    return result.length;
  }

  // INSERT ENCOUNTER
  Future<void> insertEncounter(Encounter encounter) async {
    await db.insert(Encounter.encounterTableName, encounter.toMap());
  }

  // UPDATE ENCOUNTER
  Future<void> updateEncounter(Encounter encounter) async {
    await db.update(Encounter.encounterTableName, encounter.toMap(),
        where: '${Encounter.idColumnName} = ?', whereArgs: [encounter.id]);
  }

  // DELETE ENCOUNTER
  Future<void> deleteEncounter(Encounter encounter) async {
    await db.delete(Encounter.encounterTableName,
        where: '${Encounter.idColumnName} = ?', whereArgs: [encounter.id]);
  }

  // DELETE ENCOUNTERS
  Future<void> deleteEncounters() async {
    await db.delete(Encounter.encounterTableName);
  }

  // map method for encounter
  Future<Encounter> _getEncounterFromMap(Map<String, Object?> map) async {
    final encounterId = map[Encounter.idColumnName] as String;
    final enemies = await enemyRepository.getEnemiesByEncounterId(encounterId);
    return Encounter(
      id: encounterId,
      encounterType:
          EncounterType.values[map[Encounter.encounterTypeColumnName] as int],
      questId: map[Encounter.questIdColumnName] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          map[Encounter.createdAtColumnName] as int),
      completedAt: map[Encounter.completedAtColumnName] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map[Encounter.completedAtColumnName] as int)
          : null,
      chestRarity: map[Encounter.chestRarityColumnName] != null
          ? Rarity.values[map[Encounter.chestRarityColumnName] as int]
          : null,
      enemies: enemies,
    );
  }

  /*

  --------------------------- Encounter Reward ---------------------------------

  */

  // GET ENCOUNTER REWARD BY ENCOUNTER ID
  Future<EncounterReward?> getEncounterRewardByEncounterId(
      String encounterId) async {
    final result = await db.query(EncounterReward.encounterRewardTableName,
        where: '${EncounterReward.encounterIdColumnName} = ?',
        whereArgs: [encounterId]);
    if (result.isEmpty) {
      return null;
    }
    final encounterReward = await _getEncounterRewardFromMap(result[0]);
    return encounterReward;
  }

  // GET ENCOUNTER REWARD BY QUEST ID
  Future<List<EncounterReward>> getEncounterRewardsByQuestId(
      String questId) async {
    final result = await db.query(EncounterReward.encounterRewardTableName,
        where: '${EncounterReward.questIdColumnName} = ?',
        whereArgs: [questId]);
    List<EncounterReward> encounterRewards = [];
    for (var map in result) {
      final encounterReward = await _getEncounterRewardFromMap(map);
      encounterRewards.add(encounterReward);
    }
    return encounterRewards;
  }

  // INSERT ENCOUNTER REWARD
  Future<void> insertEncounterReward(EncounterReward encounterReward) async {
    for (var equipmentReward in encounterReward.equipmentRewards) {
      await db.insert(
          EquipmentEncounterReward.equipmentEncounterRewardTableName,
          EquipmentEncounterReward(
                  id: Uuid().v4(),
                  encounterRewardId: encounterReward.id,
                  equipmentId: equipmentReward.id)
              .toMap());
      await equipmentRepository.insertEquipment(equipmentReward);
    }
    await db.insert(
        EncounterReward.encounterRewardTableName, encounterReward.toMap());
  }

  // UPDATE ENCOUNTER REWARD
  Future<void> updateEncounterReward(EncounterReward encounterReward) async {
    await db.update(
        EncounterReward.encounterRewardTableName, encounterReward.toMap(),
        where: '${EncounterReward.idColumnName} = ?',
        whereArgs: [encounterReward.id]);
  }

  // DELETE ENCOUNTER REWARD
  Future<void> deleteEncounterReward(EncounterReward encounterReward) async {
    await db.delete(EncounterReward.encounterRewardTableName,
        where: '${EncounterReward.idColumnName} = ?',
        whereArgs: [encounterReward.id]);
  }

  // DELETE ENCOUNTER REWARD BY ENCOUNTER ID
  Future<void> deleteEncounterRewardByEncounterId(String encounterId) async {
    await db.delete(EncounterReward.encounterRewardTableName,
        where: '${EncounterReward.encounterIdColumnName} = ?',
        whereArgs: [encounterId]);
  }

  // DELETE ENCOUNTER REWARD BY QUEST ID
  Future<void> deleteEncounterRewardsByQuestId(String questId) async {
    await db.delete(EncounterReward.encounterRewardTableName,
        where: '${EncounterReward.questIdColumnName} = ?',
        whereArgs: [questId]);
  }

  // map method for encounter reward
  Future<EncounterReward> _getEncounterRewardFromMap(
      Map<String, Object?> map) async {
    final equipmentRewards = await _getEquipmentByEncounterRewardId(
        map[EncounterReward.idColumnName] as String);
    return EncounterReward(
      id: map[EncounterReward.idColumnName] as String,
      encounterId: map[EncounterReward.encounterIdColumnName] as String,
      questId: map[EncounterReward.questIdColumnName] as String,
      xp: map[EncounterReward.xpColumnName] as int,
      gold: map[EncounterReward.goldColumnName] as int,
      equipmentRewards: equipmentRewards,
    );
  }

  Future<List<Equipment>> _getEquipmentByEncounterRewardId(
      String encounterRewardId) async {
    final result = await db.query(
        EquipmentEncounterReward.equipmentEncounterRewardTableName,
        where: '${EquipmentEncounterReward.encounterRewardIdColumnName} = ?',
        whereArgs: [encounterRewardId]);
    List<Equipment> equipment = [];
    for (var map in result) {
      final equipmentItem = await equipmentRepository.getEquipmentById(
          map[EquipmentEncounterReward.equipmentIdColumnName] as String);
      equipment.add(equipmentItem);
    }
    return equipment;
  }
}
