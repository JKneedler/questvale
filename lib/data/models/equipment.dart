import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/equipment_modifier.dart';
import 'package:questvale/data/models/pair.dart';

enum EquipmentType {
  helmet,
  body,
  gloves,
  boots,
  ring,
  amulet,
  oneHandedWeapon,
  twoHandedWeapon,
  shield,
  dagger,
  bow,
  wand,
  staff,
  focus,
}

enum EquipmentSlot {
  helmet,
  body,
  gloves,
  boots,
  ring,
  amulet,
  mainHandOnly,
  offHandOnly,
  twoHanded,
}

enum EquipmentRarity { common, uncommon, rare, legendary }

class Equipment {
  static const String equipmentTableName = 'Equipments';

  static const String idColumnName = 'id';
  static const String nameColumnName = 'name';
  static const String imageColumnName = 'image';
  static const String isEquippedColumnName = 'isEquipped';
  static const String levelColumnName = 'level';
  static const String armorColumnName = 'armor';
  static const String damageColumnName = 'damage';
  static const String blockChanceColumnName = 'blockChance';
  static const String typeColumnName = 'type';
  static const String slotColumnName = 'slot';
  static const String rarityColumnName = 'rarity';

  static const String createTableSQL = '''
		CREATE TABLE ${Equipment.equipmentTableName} (
			${Equipment.idColumnName} VARCHAR PRIMARY KEY,
			${Equipment.nameColumnName} VARCHAR NOT NULL,
			${Equipment.imageColumnName} VARCHAR NOT NULL,
			${Equipment.isEquippedColumnName} BOOLEAN NOT NULL,
			${Equipment.levelColumnName} INTEGER NOT NULL,
			${Equipment.armorColumnName} INTEGER NOT NULL,
			${Equipment.damageColumnName} INTEGER NOT NULL,
			${Equipment.blockChanceColumnName} INTEGER NOT NULL,
			${Equipment.typeColumnName} INTEGER NOT NULL,
			${Equipment.slotColumnName} INTEGER NOT NULL,
			${Equipment.rarityColumnName} INTEGER NOT NULL
		);
	''';

  final String id;
  final String name;
  final String image;
  final bool isEquipped;
  final int level;
  final int armor;
  final int damage;
  final int blockChance;
  final EquipmentType type;
  final EquipmentSlot slot;
  final EquipmentRarity rarity;
  final List<EquipmentModifier> modifiers;

  const Equipment({
    required this.id,
    required this.name,
    required this.image,
    required this.isEquipped,
    required this.level,
    required this.armor,
    required this.damage,
    required this.blockChance,
    required this.type,
    required this.slot,
    required this.rarity,
    required this.modifiers,
  });

  List<Pair<CombatStat, double>> get statModifiers {
    List<Pair<CombatStat, double>> statModifiers = [];
    for (EquipmentModifier modifier in modifiers) {
      statModifiers.add(modifier.statModification);
    }
    return statModifiers;
  }

  Map<String, Object?> toMap() {
    return {
      Equipment.idColumnName: id,
      Equipment.nameColumnName: name,
      Equipment.imageColumnName: image,
      Equipment.isEquippedColumnName: isEquipped ? 1 : 0,
      Equipment.levelColumnName: level,
      Equipment.armorColumnName: armor,
      Equipment.damageColumnName: damage,
      Equipment.blockChanceColumnName: blockChance,
      Equipment.typeColumnName: type.index,
      Equipment.slotColumnName: slot.index,
      Equipment.rarityColumnName: rarity.index,
    };
  }

  @override
  String toString() {
    return '''Equipment {
			id: $id
			name: $name
			image: $image
			isEquipped: $isEquipped
			level: $level
			armor: $armor
			damage: $damage
			blockChance: $blockChance
			type: $type
			slot: $slot
			rarity: $rarity
		}''';
  }

  Equipment copyWith({
    String? name,
    String? image,
    bool? isEquipped,
    int? level,
    int? armor,
    int? damage,
    int? blockChance,
    EquipmentType? type,
    EquipmentSlot? slot,
    EquipmentRarity? rarity,
    List<EquipmentModifier>? modifiers,
  }) {
    return Equipment(
      id: id,
      name: name ?? this.name,
      image: image ?? this.image,
      isEquipped: isEquipped ?? this.isEquipped,
      level: level ?? this.level,
      armor: armor ?? this.armor,
      damage: damage ?? this.damage,
      blockChance: blockChance ?? this.blockChance,
      type: type ?? this.type,
      slot: slot ?? this.slot,
      rarity: rarity ?? this.rarity,
      modifiers: modifiers ?? this.modifiers,
    );
  }
}
