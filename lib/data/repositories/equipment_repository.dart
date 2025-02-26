import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/inventory_equipment.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/equipment_modifier.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class EquipmentRepository {
  final Database db;

  EquipmentRepository({required this.db});

  // GET by id
  Future<Equipment> getById(String id) async {
    final equipmentMaps = await db.query(
      Equipment.equipmentTableName,
      where: '${Equipment.idColumnName} = ?',
      whereArgs: [id],
      limit: 1,
    );
    final equipment = await _getEquipmentFromMap(equipmentMaps[0]);
    return equipment;
  }

  // GET by character id
  Future<List<Equipment>> getByInventoryId(String inventoryId) async {
    // Get CharacterEquipments
    final inventoryEquipments = await db.query(
      InventoryEquipment.inventoryEquipmentTableName,
      where: '${InventoryEquipment.inventoryColumnName} = ?',
      whereArgs: [inventoryId],
    );
    // Get Equipment from each CharacterEquipments
    final equipmentMaps = await db.query(
      Equipment.equipmentTableName,
      where:
          '${Equipment.idColumnName} IN (${List.filled(inventoryEquipments.length, '?').join(',')})',
      whereArgs: inventoryEquipments
          .map((map) => map[InventoryEquipment.equipmentColumnName])
          .toList(),
    );
    final equipments = [
      for (Map<String, Object?> map in equipmentMaps)
        await _getEquipmentFromMap(map)
    ];
    return equipments;
  }

  // UPDATE
  Future<void> updateOnlyEquipment(Equipment updateEquipment) async {
    await db.update(
      Equipment.equipmentTableName,
      updateEquipment.toMap(),
      where: '${Equipment.idColumnName} = ?',
      whereArgs: [updateEquipment.id],
    );
  }

  // INSERT
  Future<void> insertEquipment(Equipment insertEquipment) async {
    await db.insert(
      Equipment.equipmentTableName,
      insertEquipment.toMap(),
    );
    for (EquipmentModifier modifier in insertEquipment.modifiers) {
      await db.insert(
        EquipmentModifier.equipmentModifierTableName,
        modifier.toMap(),
      );
    }
  }

  // INSERT link between character and equipment
  Future<void> insertInventoryEquipmentLink(
      String inventoryId, String equipmentId) async {
    await db.insert(
      InventoryEquipment.inventoryEquipmentTableName,
      InventoryEquipment(
        id: Uuid().v1(),
        inventoryId: inventoryId,
        equipmentId: equipmentId,
      ).toMap(),
    );
  }

  // DELETE
  Future<void> deleteEquipment(String id) async {
    await db.delete(
      EquipmentModifier.equipmentModifierTableName,
      where: '${EquipmentModifier.equipmentColumnName} = ?',
      whereArgs: [id],
    );

    await db.delete(
      Equipment.equipmentTableName,
      where: '${Equipment.idColumnName} = ?',
      whereArgs: [id],
    );
  }

  // private get model from map
  Future<Equipment> _getEquipmentFromMap(Map<String, Object?> map) async {
    final modifiers = await _getEquipmentModifiersByCharacterId(
        map[Equipment.idColumnName] as String);
    final equipment = Equipment(
      id: map[Equipment.idColumnName] as String,
      name: map[Equipment.nameColumnName] as String,
      image: map[Equipment.imageColumnName] as String,
      isEquipped: map[Equipment.isEquippedColumnName] == 1 ? true : false,
      level: map[Equipment.levelColumnName] as int,
      armor: map[Equipment.armorColumnName] as int,
      damage: map[Equipment.damageColumnName] as int,
      blockChance: map[Equipment.blockChanceColumnName] as int,
      type: EquipmentType.values[map[Equipment.typeColumnName] as int],
      slot: EquipmentSlot.values[map[Equipment.slotColumnName] as int],
      rarity: EquipmentRarity.values[map[Equipment.rarityColumnName] as int],
      modifiers: modifiers,
    );
    return equipment;
  }

  // private get modifiers
  Future<List<EquipmentModifier>> _getEquipmentModifiersByCharacterId(
      String id) async {
    final modifierMaps = await db.query(
      EquipmentModifier.equipmentModifierTableName,
      where: '${EquipmentModifier.equipmentColumnName} = ?',
      whereArgs: [id],
    );
    final modifiers = [
      for (final map in modifierMaps)
        EquipmentModifier(
          id: map[EquipmentModifier.idColumnName] as String,
          equipmentId: map[EquipmentModifier.equipmentColumnName] as String,
          type: EquipmentModifierType
              .values[map[EquipmentModifier.typeColumnName] as int],
          stat: CombatStat.values[map[EquipmentModifier.statColumnName] as int],
          value: map[EquipmentModifier.valueColumnName] as double,
        )
    ];
    return modifiers;
  }
}
