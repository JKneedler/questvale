class InventoryEquipment {
  static const inventoryEquipmentTableName = 'InventoryEquipments';

  static const idColumnName = 'id';
  static const inventoryColumnName = 'inventory';
  static const equipmentColumnName = 'equipment';

  static const createTableSQL = '''
		CREATE TABLE ${InventoryEquipment.inventoryEquipmentTableName} (
			${InventoryEquipment.idColumnName} VARCHAR PRIMARY KEY,
			${InventoryEquipment.inventoryColumnName} VARCHAR NOT NULL,
			${InventoryEquipment.equipmentColumnName} VARCHAR NOT NULL
		);
	''';

  final String id;
  final String inventoryId;
  final String equipmentId;

  const InventoryEquipment({
    required this.id,
    required this.inventoryId,
    required this.equipmentId,
  });

  Map<String, Object?> toMap() {
    return {
      InventoryEquipment.idColumnName: id,
      InventoryEquipment.inventoryColumnName: inventoryId,
      InventoryEquipment.equipmentColumnName: equipmentId,
    };
  }

  @override
  String toString() {
    return 'InventoryEquipment { id: $id, inventory: $inventoryId, equipment: $equipmentId }';
  }

  InventoryEquipment copyWith({
    String? inventoryId,
    String? equipmentId,
  }) {
    return InventoryEquipment(
      id: id,
      inventoryId: inventoryId ?? this.inventoryId,
      equipmentId: equipmentId ?? this.equipmentId,
    );
  }
}
