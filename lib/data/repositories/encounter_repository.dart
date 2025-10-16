import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:sqflite/sqflite.dart';

class EncounterRepository {
  final Database db;

  late EnemyRepository enemyRepository;

  EncounterRepository({required this.db}) {
    enemyRepository = EnemyRepository(db: db);
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
      encounterCompleted:
          map[Encounter.encounterCompletedColumnName] as int == 1,
      questId: map[Encounter.questIdColumnName] as String,
      enemies: enemies,
    );
  }
}
