import 'dart:math';

import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/equipment_modifier.dart';
import 'package:uuid/uuid.dart';

class EquipmentService {
  Equipment? generateEquipment(int equipmentLevel) {
    final String id = Uuid().v4();
    final type =
        EquipmentType.values[Random().nextInt(EquipmentType.values.length)];

    EquipmentRarity rarity = EquipmentRarity.common;
    int numOfModifiers = 0;
    final rarityVal = Random().nextInt(10);
    if (rarityVal < 6) {
      rarity = EquipmentRarity.common;
    } else if (rarityVal < 9) {
      rarity = EquipmentRarity.uncommon;
      numOfModifiers = 1;
    } else {
      rarity = EquipmentRarity.rare;
      numOfModifiers = 2 + Random().nextInt(2);
    }
    List<EquipmentModifier> modifiers = [
      for (int i = 0; i < numOfModifiers; i++)
        generateModifier(type, id, equipmentLevel)
    ];

    String name = '';
    String image = '';
    int armor = 0;
    int damage = 0;
    int blockChance = 0;
    EquipmentSlot slot = EquipmentSlot.helmet;

    switch (type) {
      case EquipmentType.helmet:
        name = 'Iron Helmet';
        image = 'images/helmet.png';
        armor = 4;
        slot = EquipmentSlot.helmet;
        break;
      case EquipmentType.body:
        name = 'Iron Chest';
        image = 'images/body.png';
        armor = 8;
        slot = EquipmentSlot.body;
        break;
      case EquipmentType.gloves:
        name = 'Iron Gauntlets';
        image = 'images/gloves.png';
        armor = 2;
        slot = EquipmentSlot.gloves;
        break;
      case EquipmentType.boots:
        name = 'Iron Boots';
        image = 'images/boots.png';
        armor = 2;
        slot = EquipmentSlot.boots;
        break;
      case EquipmentType.ring:
        name = 'Gold Ring';
        image = 'images/ring.png';
        slot = EquipmentSlot.ring;
        break;
      case EquipmentType.amulet:
        name = 'Emerald Amulet';
        image = 'images/amulet.png';
        slot = EquipmentSlot.amulet;
        break;
      case EquipmentType.oneHandedWeapon:
        name = 'Iron Sword';
        image = 'images/sword.png';
        damage = 5;
        slot = EquipmentSlot.mainHandOnly;
        break;
      case EquipmentType.twoHandedWeapon:
        name = 'Iron Greatsword';
        image = 'images/greatsword.png';
        damage = 8;
        slot = EquipmentSlot.twoHanded;
        break;
      case EquipmentType.shield:
        image = 'images/shield.png';
        name = 'Iron Shield';
        armor = 2;
        blockChance = 10;
        slot = EquipmentSlot.offHandOnly;
        break;
      case EquipmentType.dagger:
        name = 'Iron Daggers';
        image = 'images/daggers.png';
        damage = 3;
        slot = EquipmentSlot.twoHanded;
        break;
      case EquipmentType.bow:
        name = 'Hunter Bow';
        image = 'images/bow.png';
        damage = 6;
        slot = EquipmentSlot.twoHanded;
        break;
      case EquipmentType.wand:
        name = 'Apprentice Wand';
        image = 'images/wand.png';
        damage = 4;
        slot = EquipmentSlot.mainHandOnly;
        break;
      case EquipmentType.staff:
        name = 'Apprentice Staff';
        image = 'images/staff.png';
        damage = 6;
        slot = EquipmentSlot.twoHanded;
        break;
      case EquipmentType.focus:
        name = 'Leatherbound Book';
        image = 'images/book.png';
        damage = 5;
        slot = EquipmentSlot.offHandOnly;
        break;
      default:
        return null;
    }

    return Equipment(
      id: id,
      name: name,
      image: image,
      isEquipped: false,
      level: equipmentLevel,
      armor: armor,
      damage: damage,
      blockChance: blockChance,
      type: type,
      slot: slot,
      rarity: rarity,
      modifiers: modifiers,
    );
  }

  EquipmentModifier generateModifier(
      EquipmentType type, String equipmentId, int modifierLevel) {
    final modifierList =
        EquipmentModifier.equipmentTypeModifierMap[type.index]!;
    EquipmentModifierType modifierType = EquipmentModifierType
        .values[modifierList[Random().nextInt(modifierList.length)]];
    final modifierInfo = EquipmentModifier.modiferInfoMap[modifierType]!;
    return EquipmentModifier(
        id: Uuid().v4(),
        equipmentId: equipmentId,
        type: modifierType,
        stat: modifierInfo['stat'] as CombatStat,
        value: modifierInfo['baseValue'] as double);
  }
}
