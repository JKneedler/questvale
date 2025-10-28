import 'package:questvale/data/models/stat_modifier.dart';
import 'package:questvale/helpers/shared_enums.dart';

enum EquipmentType {
  swordAndShield,
  twoHandedSword,
  daggers,
  bow,
  wandAndFocus,
  staff,
  helmet,
  chestplate,
  gloves,
  boots,
  amulet,
  ring;

  String className(CharacterClass classType) {
    switch (classType) {
      case CharacterClass.warrior:
        if (this == helmet) {
          return 'Helmet';
        } else if (this == chestplate) {
          return 'Chestplate';
        } else if (this == gloves) {
          return 'Gauntlets';
        } else if (this == boots) {
          return 'Boots';
        }
        return '';
      case CharacterClass.rogue:
        if (this == helmet) {
          return 'Hood';
        } else if (this == chestplate) {
          return 'Cloak';
        } else if (this == gloves) {
          return 'Gloves';
        } else if (this == boots) {
          return 'Boots';
        }
        return '';
      case CharacterClass.mage:
        if (this == helmet) {
          return 'Hood';
        } else if (this == chestplate) {
          return 'Robe';
        } else if (this == gloves) {
          return 'Gloves';
        } else if (this == boots) {
          return 'Boots';
        }
        return '';
    }
  }

  EquipmentSlot get slot {
    switch (this) {
      case EquipmentType.swordAndShield:
        return EquipmentSlot.weapon;
      case EquipmentType.twoHandedSword:
        return EquipmentSlot.weapon;
      case EquipmentType.daggers:
        return EquipmentSlot.weapon;
      case EquipmentType.bow:
        return EquipmentSlot.weapon;
      case EquipmentType.wandAndFocus:
        return EquipmentSlot.weapon;
      case EquipmentType.staff:
        return EquipmentSlot.weapon;
      case EquipmentType.helmet:
        return EquipmentSlot.head;
      case EquipmentType.chestplate:
        return EquipmentSlot.body;
      case EquipmentType.gloves:
        return EquipmentSlot.hands;
      case EquipmentType.boots:
        return EquipmentSlot.feet;
      case EquipmentType.amulet:
        return EquipmentSlot.neck;
      case EquipmentType.ring:
        return EquipmentSlot.ring;
    }
  }

  int get actionPointCost {
    if ([
      EquipmentType.swordAndShield,
      EquipmentType.daggers,
      EquipmentType.wandAndFocus,
    ].contains(this)) {
      return 1;
    } else if ([
      EquipmentType.twoHandedSword,
      EquipmentType.bow,
      EquipmentType.staff
    ].contains(this)) {
      return 2;
    } else {
      return 0;
    }
  }

  static List<EquipmentType> availableEquipmentTypes(CharacterClass classType) {
    switch (classType) {
      case CharacterClass.warrior:
        return [
          EquipmentType.swordAndShield,
          EquipmentType.twoHandedSword,
          EquipmentType.helmet,
          EquipmentType.chestplate,
          EquipmentType.gloves,
          EquipmentType.boots,
          EquipmentType.amulet,
          EquipmentType.ring,
        ];
      case CharacterClass.rogue:
        return [
          EquipmentType.daggers,
          EquipmentType.bow,
          EquipmentType.helmet,
          EquipmentType.chestplate,
          EquipmentType.gloves,
          EquipmentType.boots,
          EquipmentType.amulet,
          EquipmentType.ring,
        ];
      case CharacterClass.mage:
        return [
          EquipmentType.wandAndFocus,
          EquipmentType.staff,
          EquipmentType.helmet,
          EquipmentType.chestplate,
          EquipmentType.gloves,
          EquipmentType.boots,
          EquipmentType.amulet,
          EquipmentType.ring,
        ];
    }
  }
}

enum EquipmentSlot {
  weapon,
  head,
  body,
  hands,
  feet,
  neck,
  ring;

  List<int> get slotTypes {
    switch (this) {
      case EquipmentSlot.weapon:
        return [
          EquipmentType.swordAndShield.index,
          EquipmentType.twoHandedSword.index,
          EquipmentType.daggers.index,
          EquipmentType.bow.index,
          EquipmentType.wandAndFocus.index,
          EquipmentType.staff.index,
        ];
      case EquipmentSlot.head:
        return [
          EquipmentType.helmet.index,
        ];
      case EquipmentSlot.body:
        return [
          EquipmentType.chestplate.index,
        ];
      case EquipmentSlot.hands:
        return [
          EquipmentType.gloves.index,
        ];
      case EquipmentSlot.feet:
        return [
          EquipmentType.boots.index,
        ];
      case EquipmentSlot.neck:
        return [
          EquipmentType.amulet.index,
        ];
      case EquipmentSlot.ring:
        return [
          EquipmentType.ring.index,
        ];
      default:
        return [];
    }
  }
}

enum MageTier {
  apprentice,
  ashen,
  azure,
  verdant,
  solar,
  ember,
  amethyst,
  umbral;
}

class Equipment {
  static const equipmentTableName = 'Equipments';

  static const idColumnName = 'id';
  static const characterIdColumnName = 'characterId';
  static const isEquippedColumnName = 'isEquipped';
  static const rarityColumnName = 'rarity';
  static const typeColumnName = 'type';
  static const tierColumnName = 'tier';
  static const attackPowerColumnName = 'attackPower';
  static const actionPointCostColumnName = 'actionPointCost';
  static const damageTypeColumnName = 'damageType';
  static const armorValueColumnName = 'armorValue';

  static const createTableSQL = '''
    CREATE TABLE $equipmentTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $characterIdColumnName VARCHAR NOT NULL,
      $isEquippedColumnName BOOLEAN NOT NULL,
      $rarityColumnName INTEGER NOT NULL,
      $typeColumnName INTEGER NOT NULL,
      $tierColumnName INTEGER NOT NULL,
      $attackPowerColumnName INTEGER NOT NULL,
      $actionPointCostColumnName INTEGER NOT NULL,
      $damageTypeColumnName INTEGER NOT NULL,
      $armorValueColumnName INTEGER NOT NULL
    );
  ''';

  final String id;
  final String characterId;
  final bool isEquipped;
  final Rarity rarity;
  final EquipmentType type;
  final int tier;
  final int attackPower;
  final int actionPointCost;
  final DamageType damageType;
  final int armorValue;
  final List<StatModifier> statModifiers;

  const Equipment({
    required this.id,
    required this.characterId,
    required this.isEquipped,
    required this.rarity,
    required this.type,
    required this.tier,
    required this.attackPower,
    required this.actionPointCost,
    required this.damageType,
    required this.armorValue,
    required this.statModifiers,
  });

  Map<String, Object?> toMap() {
    return {
      idColumnName: id,
      characterIdColumnName: characterId,
      isEquippedColumnName: isEquipped ? 1 : 0,
      rarityColumnName: rarity.index,
      typeColumnName: type.index,
      tierColumnName: tier,
      attackPowerColumnName: attackPower,
      actionPointCostColumnName: actionPointCost,
      damageTypeColumnName: damageType.index,
      armorValueColumnName: armorValue,
    };
  }

  @override
  String toString() {
    return 'Equipment(id: $id, characterId: $characterId, isEquipped: $isEquipped, rarity: $rarity, type: $type, tier: $tier, attackPower: $attackPower, actionPointCost: $actionPointCost, damageType: $damageType, armorValue: $armorValue)';
  }

  String iconPath(CharacterClass characterClass) {
    final classItemName = type.className(characterClass).toLowerCase();
    final itemName =
        classItemName == '' ? type.name.toLowerCase() : classItemName;
    final classString = characterClass.name.toLowerCase();
    return 'images/equipment/${classItemName != '' ? '$classString-' : ''}$itemName-$tier.png';
  }

  String itemName(EquipmentType equipmentType, CharacterClass classType) {
    if (classType == CharacterClass.mage) {
      String base = '';
      if (equipmentType == EquipmentType.wandAndFocus) {
        base = 'Wand and Focus';
      } else if (equipmentType == EquipmentType.staff) {
        base = 'Staff';
      } else if (equipmentType == EquipmentType.helmet ||
          equipmentType == EquipmentType.chestplate ||
          equipmentType == EquipmentType.gloves ||
          equipmentType == EquipmentType.boots) {
        base = equipmentType.className(classType);
      } else if (equipmentType == EquipmentType.amulet) {
        base = 'Amulet';
      } else if (equipmentType == EquipmentType.ring) {
        base = 'Ring';
      }
      final tierBaseName = MageTier.values[tier - 1].name;
      final tierName = tierBaseName.substring(0, 1).toUpperCase() +
          tierBaseName.substring(1);
      return '$tierName $base';
    } else {
      return equipmentType.name.toLowerCase();
    }
  }

  Equipment copyWith({
    String? id,
    String? characterId,
    bool? isEquipped,
    Rarity? rarity,
    EquipmentType? type,
    int? tier,
    int? attackPower,
    int? actionPointCost,
    DamageType? damageType,
    int? armorValue,
    List<StatModifier>? statModifiers,
  }) {
    return Equipment(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      isEquipped: isEquipped ?? this.isEquipped,
      rarity: rarity ?? this.rarity,
      type: type ?? this.type,
      tier: tier ?? this.tier,
      attackPower: attackPower ?? this.attackPower,
      actionPointCost: actionPointCost ?? this.actionPointCost,
      damageType: damageType ?? this.damageType,
      armorValue: armorValue ?? this.armorValue,
      statModifiers: statModifiers ?? this.statModifiers,
    );
  }
}
