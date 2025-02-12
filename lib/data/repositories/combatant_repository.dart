import 'package:questvale/data/models/combatant.dart';
import 'package:sqflite/sqflite.dart';

class CombatantRepository {
  final Database db;

  CombatantRepository({required this.db});

  // GET by id
  Future<Combatant> getCombatantById(String id) async {
    final combatantMap = await db.query(
      Combatant.combatantTableName,
      where: '${Combatant.idColumnName} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return _getCombatantFromMap(combatantMap[0]);
  }

  // GET by questRoomId
  Future<List<Combatant>> getCombatantsByQuestRoomId(String id) async {
    final combatantMaps = await db.query(
      Combatant.combatantTableName,
      where: '${Combatant.questRoomColumnName} = ?',
      whereArgs: [id],
    );
    final combatants = [
      for (final map in combatantMaps) _getCombatantFromMap(map)
    ];
    return combatants;
  }

  // CREATE combatant
  Future<void> addCombatant(Combatant combatant) async {
    await db.insert(
      Combatant.combatantTableName,
      combatant.toMap(),
    );
  }

  // UPDATE
  Future<void> updateCombatant(Combatant updateCombatant) async {
    await db.update(
      Combatant.combatantTableName,
      updateCombatant.toMap(),
      where: '${Combatant.idColumnName} = ?',
      whereArgs: [updateCombatant.id],
    );
  }

  Combatant _getCombatantFromMap(Map<String, Object?> map) {
    return Combatant(
      id: map[Combatant.idColumnName] as String,
      questRoomId: map[Combatant.questRoomColumnName] as String,
      name: map[Combatant.nameColumnName] as String,
      currentHealth: map[Combatant.currentHealthColumnName] as int,
      maxHealth: map[Combatant.maxHealthColumnName] as int,
      attackDamage: map[Combatant.attackDamageColumnName] as int,
      attackInterval: map[Combatant.attackIntervalColumnName] as int,
      lastAttack: map[Combatant.lastAttackColumnName] as String,
    );
  }
}
