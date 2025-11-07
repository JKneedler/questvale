import 'package:questvale/data/models/stat_modifier.dart';
import 'package:sqflite/sqflite.dart';

class StatModifiersRepository {
  final Database db;

  StatModifiersRepository({required this.db});

  /*

  --------------------------- Stat Modifiers ---------------------------------

  */

  // GET STAT MODIFIERS BY EQUIPMENT ID
  Future<List<StatModifier>> getStatModifiersByEquipmentId(
      String equipmentId) async {
    final result = await db.query(StatModifier.statModifierTableName,
        where: '${StatModifier.equipmentIdColumnName} = ?',
        whereArgs: [equipmentId]);
    List<StatModifier> statModifiers = [];
    for (var map in result) {
      statModifiers.add(_getStatModifierFromMap(map));
    }
    return statModifiers;
  }

  // GET STAT MODIFIERS BY CHARACTER ID
  Future<List<StatModifier>> getStatModifiersByCharacterId(
      String characterId) async {
    final result = await db.query(StatModifier.statModifierTableName,
        where: '${StatModifier.characterIdColumnName} = ?',
        whereArgs: [characterId]);
    List<StatModifier> statModifiers = [];
    for (var map in result) {
      statModifiers.add(_getStatModifierFromMap(map));
    }
    return statModifiers;
  }

  // GET STAT MODIFIERS BY GEM ID
  Future<List<StatModifier>> getStatModifiersByGemId(String gemId) async {
    final result = await db.query(StatModifier.statModifierTableName,
        where: '${StatModifier.gemIdColumnName} = ?', whereArgs: [gemId]);
    List<StatModifier> statModifiers = [];
    for (var map in result) {
      statModifiers.add(_getStatModifierFromMap(map));
    }
    return statModifiers;
  }

  // GET STAT MODIFIERS BY POTION ID
  Future<List<StatModifier>> getStatModifiersByPotionId(String potionId) async {
    final result = await db.query(StatModifier.statModifierTableName,
        where: '${StatModifier.potionIdColumnName} = ?', whereArgs: [potionId]);
    List<StatModifier> statModifiers = [];
    for (var map in result) {
      statModifiers.add(_getStatModifierFromMap(map));
    }
    return statModifiers;
  }

  // INSERT STAT MODIFIER
  Future<void> insertStatModifier(StatModifier statModifier) async {
    await db.insert(StatModifier.statModifierTableName, statModifier.toMap());
  }

  // UPDATE STAT MODIFIER
  Future<void> updateStatModifier(StatModifier statModifier) async {
    await db.update(StatModifier.statModifierTableName, statModifier.toMap(),
        where: '${StatModifier.idColumnName} = ?',
        whereArgs: [statModifier.id]);
  }

  // DELETE STAT MODIFIER
  Future<void> deleteStatModifier(String statModifierId) async {
    await db.delete(StatModifier.statModifierTableName,
        where: '${StatModifier.idColumnName} = ?', whereArgs: [statModifierId]);
  }

  // DELETE STAT MODIFIERS BY EQUIPMENT ID
  Future<void> deleteStatModifiersByEquipmentId(String equipmentId) async {
    await db.delete(StatModifier.statModifierTableName,
        where: '${StatModifier.equipmentIdColumnName} = ?',
        whereArgs: [equipmentId]);
  }

  // DELETE STAT MODIFIERS BY CHARACTER ID
  Future<void> deleteStatModifiersByCharacterId(String characterId) async {
    await db.delete(StatModifier.statModifierTableName,
        where: '${StatModifier.characterIdColumnName} = ?',
        whereArgs: [characterId]);
  }

  // DELETE STAT MODIFIERS BY GEM ID
  Future<void> deleteStatModifiersByGemId(String gemId) async {
    await db.delete(StatModifier.statModifierTableName,
        where: '${StatModifier.gemIdColumnName} = ?', whereArgs: [gemId]);
  }

  // DELETE STAT MODIFIERS BY POTION ID
  Future<void> deleteStatModifiersByPotionId(String potionId) async {
    await db.delete(StatModifier.statModifierTableName,
        where: '${StatModifier.potionIdColumnName} = ?', whereArgs: [potionId]);
  }

  // map method for stat modifier
  StatModifier _getStatModifierFromMap(Map<String, Object?> map) {
    return StatModifier(
      id: map[StatModifier.idColumnName] as String,
      location: StatModifierLocation
          .values[map[StatModifier.locationColumnName] as int],
      characterId: map[StatModifier.characterIdColumnName] as String?,
      equipmentId: map[StatModifier.equipmentIdColumnName] as String?,
      gemId: map[StatModifier.gemIdColumnName] as String?,
      potionId: map[StatModifier.potionIdColumnName] as String?,
      type: StatModifierType.values[map[StatModifier.typeColumnName] as int],
      tier: map[StatModifier.tierColumnName] as int,
    );
  }
}
