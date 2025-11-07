import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/repositories/stat_modifiers_repository.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:sqflite/sqflite.dart';

class EquipmentRepository {
  final Database db;

  late StatModifiersRepository statModifiersRepository;

  EquipmentRepository({required this.db}) {
    statModifiersRepository = StatModifiersRepository(db: db);
  }

  /*

  --------------------------- Equipment ---------------------------------

  */

  // GET EQUIPMENT BY CHARACTER ID
  Future<List<Equipment>> getEquipmentByCharacterId(String characterId) async {
    final result = await db.query(Equipment.equipmentTableName,
        where: '${Equipment.characterIdColumnName} = ?',
        whereArgs: [characterId]);
    List<Equipment> equipment = [];
    for (var map in result) {
      final equipmentItem = await _getEquipmentFromMap(map);
      equipment.add(equipmentItem);
    }
    return equipment;
  }

  // GET EQUIPPED EQUIPMENT BY CHARACTER ID
  Future<List<Equipment>> getEquippedEquipmentByCharacterId(
      String characterId) async {
    final result = await db.query(Equipment.equipmentTableName,
        where:
            '${Equipment.characterIdColumnName} = ? AND ${Equipment.isEquippedColumnName} = 1',
        whereArgs: [characterId]);
    List<Equipment> equipment = [];
    for (var map in result) {
      final equipmentItem = await _getEquipmentFromMap(map);
      equipment.add(equipmentItem);
    }
    return equipment;
  }

  // GET EQUIPMENT BY EQUIPMENT SLOT
  Future<List<Equipment>> getEquipmentByEquipmentSlot(
      EquipmentSlot equipmentSlot, String characterId) async {
    final slotTypes = equipmentSlot.slotTypes;
    final result = await db.query(Equipment.equipmentTableName,
        where:
            '${Equipment.typeColumnName} IN (${List.filled(slotTypes.length, '?').join(',')}) AND ${Equipment.characterIdColumnName} = ?',
        whereArgs: [...slotTypes, characterId]);
    List<Equipment> equipment = [];
    for (var map in result) {
      equipment.add(await _getEquipmentFromMap(map));
    }
    return equipment;
  }

  // GET EQUIPMENT BY ID
  Future<Equipment> getEquipmentById(String equipmentId) async {
    final result = await db.query(Equipment.equipmentTableName,
        where: '${Equipment.idColumnName} = ?', whereArgs: [equipmentId]);
    if (result.isEmpty) {
      throw Exception('Equipment $equipmentId not found');
    }
    return _getEquipmentFromMap(result[0]);
  }

  // INSERT EQUIPMENT
  Future<void> insertEquipment(Equipment equipment) async {
    await db.insert(Equipment.equipmentTableName, equipment.toMap());
    for (var statModifier in equipment.statModifiers) {
      await statModifiersRepository.insertStatModifier(statModifier);
    }
  }

  // UPDATE EQUIPMENT
  Future<void> updateEquipment(Equipment equipment) async {
    await db.update(Equipment.equipmentTableName, equipment.toMap(),
        where: '${Equipment.idColumnName} = ?', whereArgs: [equipment.id]);
  }

  // DELETE EQUIPMENT
  Future<void> deleteEquipment(String equipmentId) async {
    await db.delete(Equipment.equipmentTableName,
        where: '${Equipment.idColumnName} = ?', whereArgs: [equipmentId]);
    await statModifiersRepository.deleteStatModifiersByEquipmentId(equipmentId);
  }

  // map method for equipment
  Future<Equipment> _getEquipmentFromMap(Map<String, Object?> map) async {
    final statModifiers = await statModifiersRepository
        .getStatModifiersByEquipmentId(map[Equipment.idColumnName] as String);
    return Equipment(
      id: map[Equipment.idColumnName] as String,
      characterId: map[Equipment.characterIdColumnName] as String,
      isEquipped: map[Equipment.isEquippedColumnName] as int == 1,
      rarity: Rarity.values[map[Equipment.rarityColumnName] as int],
      type: EquipmentType.values[map[Equipment.typeColumnName] as int],
      tier: map[Equipment.tierColumnName] as int,
      attackPower: map[Equipment.attackPowerColumnName] as int,
      actionPointCost: map[Equipment.actionPointCostColumnName] as int,
      damageType: DamageType.values[map[Equipment.damageTypeColumnName] as int],
      armorValue: map[Equipment.armorValueColumnName] as int,
      statModifiers: statModifiers,
    );
  }
}
