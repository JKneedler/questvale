import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/pair.dart';

class Inventory {
  static const String inventoryTableName = 'Inventories';

  static const String idColumnName = 'id';
  static const String goldColumnName = 'gold';
  static const String helmetColumnName = 'helmet';
  static const String bodyColumnName = 'body';
  static const String glovesColumnName = 'gloves';
  static const String bootsColumnName = 'boots';
  static const String ringColumnName = 'ring';
  static const String amuletColumnName = 'amulet';
  static const String mainHandColumnName = 'mainHand';
  static const String offHandColumnName = 'offHand';

  static const String createTableSQL = '''
		CREATE TABLE ${Inventory.inventoryTableName} (
			${Inventory.idColumnName} VARCHAR PRIMARY KEY,
			${Inventory.goldColumnName} INTEGER NOT NULL,
			${Inventory.helmetColumnName} VARCHAR,
			${Inventory.bodyColumnName} VARCHAR,
			${Inventory.glovesColumnName} VARCHAR,
			${Inventory.bootsColumnName} VARCHAR,
			${Inventory.ringColumnName} VARCHAR,
			${Inventory.amuletColumnName} VARCHAR,
			${Inventory.mainHandColumnName} VARCHAR,
			${Inventory.offHandColumnName} VARCHAR
		);
	''';

  final String id;
  final int gold;
  final Equipment? helmet;
  final Equipment? body;
  final Equipment? gloves;
  final Equipment? boots;
  final Equipment? ring;
  final Equipment? amulet;
  final Equipment? mainHand;
  final Equipment? offHand;
  final List<Equipment> equipments;

  const Inventory({
    required this.id,
    required this.gold,
    this.helmet,
    this.body,
    this.gloves,
    this.boots,
    this.ring,
    this.amulet,
    this.mainHand,
    this.offHand,
    required this.equipments,
  });

  int get baseDamage {
    if (mainHand != null && mainHand?.slot == EquipmentSlot.twoHanded) {
      return mainHand!.damage;
    } else {
      return (mainHand != null ? mainHand!.damage : 0) +
          (offHand != null ? offHand!.damage : 0);
    }
  }

  int get baseArmor =>
      (helmet != null ? helmet!.armor : 0) +
      (body != null ? body!.armor : 0) +
      (gloves != null ? gloves!.armor : 0) +
      (boots != null ? boots!.armor : 0);

  int get baseBlockChance =>
      (offHand != null && offHand?.type == EquipmentType.shield
          ? offHand!.blockChance
          : 0);

  double get baseCritChance => .05;
  double get baseCritDamageMult => 2;

  List<Pair<CombatStat, double>> get statModifiers {
    List<Pair<CombatStat, double>> statModifiers = [];
    if (helmet != null) statModifiers.addAll(helmet!.statModifiers);
    if (body != null) statModifiers.addAll(body!.statModifiers);
    if (gloves != null) statModifiers.addAll(gloves!.statModifiers);
    if (boots != null) statModifiers.addAll(boots!.statModifiers);
    if (ring != null) statModifiers.addAll(ring!.statModifiers);
    if (amulet != null) statModifiers.addAll(amulet!.statModifiers);
    if (mainHand != null) statModifiers.addAll(mainHand!.statModifiers);
    if (offHand != null && offHand!.slot != EquipmentSlot.twoHanded) {
      statModifiers.addAll(offHand!.statModifiers);
    }
    return statModifiers;
  }

  Map<String, Object?> toMap() {
    return {
      Inventory.idColumnName: id,
      Inventory.goldColumnName: gold,
      Inventory.helmetColumnName: helmet?.id,
      Inventory.bodyColumnName: body?.id,
      Inventory.glovesColumnName: gloves?.id,
      Inventory.bootsColumnName: boots?.id,
      Inventory.ringColumnName: ring?.id,
      Inventory.amuletColumnName: amulet?.id,
      Inventory.mainHandColumnName: mainHand?.id,
      Inventory.offHandColumnName: offHand?.id,
    };
  }

  @override
  String toString() {
    return '''Inventory {
			id: $id
			gold: $gold
			helmet: ${helmet?.id}
			body: ${body?.id}
			gloves: ${gloves?.id}
			boots: ${boots?.id}
			ring: ${ring?.id}
			amulet: ${amulet?.id}
			mainHand: ${mainHand?.id}
			offHand: ${offHand?.id}
			equipment: ${equipments.length}
		}''';
  }

  Inventory copyWith({
    int? gold,
    Equipment? helmet,
    Equipment? body,
    Equipment? gloves,
    Equipment? boots,
    Equipment? ring,
    Equipment? amulet,
    Equipment? mainHand,
    Equipment? offHand,
    List<Equipment>? equipments,
  }) {
    return Inventory(
      id: id,
      gold: gold ?? this.gold,
      helmet: helmet ?? this.helmet,
      body: body ?? this.body,
      gloves: gloves ?? this.gloves,
      boots: boots ?? this.boots,
      ring: ring ?? this.ring,
      amulet: amulet ?? this.amulet,
      mainHand: mainHand ?? this.mainHand,
      offHand: offHand ?? this.offHand,
      equipments: equipments ?? this.equipments,
    );
  }
}
