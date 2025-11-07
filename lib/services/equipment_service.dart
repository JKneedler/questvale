import 'dart:math';

import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/providers/game_data_models/quest_zone.dart';
import 'package:questvale/data/models/stat_modifier.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:questvale/data/repositories/stat_modifiers_repository.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class EquipmentService {
  final Database db;
  late EquipmentRepository equipmentRepository;
  late StatModifiersRepository statModifiersRepository;
  EquipmentService({required this.db}) {
    equipmentRepository = EquipmentRepository(db: db);
    statModifiersRepository = StatModifiersRepository(db: db);
  }

  Equipment generateEquipment(
      Character character, QuestZone questZone, EncounterType encounterType) {
    return Equipment(
      id: Uuid().v4(),
      characterId: character.id,
      isEquipped: false,
      rarity: Rarity.common,
      type: EquipmentType.swordAndShield,
      tier: 1,
      attackPower: 10,
      actionPointCost: 10,
      damageType: DamageType.physical,
      armorValue: 10,
      statModifiers: [],
    );
  }

  Future<void> upgradeEquipment(Equipment equipment) async {
    final newStatModifier =
        generateRandomTestStatModifier(equipment.id, equipment.type.slot);
    await statModifiersRepository.insertStatModifier(newStatModifier);
    final upgradedEquipment = equipment.copyWith(
      rarity: Rarity.values[equipment.rarity.index + 1],
    );
    await equipmentRepository.updateEquipment(upgradedEquipment);
  }

  Equipment generateRandomTestEquipment(
      Character character, QuestZone questZone, EncounterType encounterType) {
    final equipmentId = Uuid().v4();
    final availableEquipmentTypes =
        EquipmentType.availableEquipmentTypes(character.characterClass);
    final equipmentType = availableEquipmentTypes[
        Random().nextInt(availableEquipmentTypes.length)];
    final attackPower = equipmentType.slot == EquipmentSlot.weapon
        ? Random().nextInt(10) + 1
        : 0;
    final armorValue = equipmentType.slot != EquipmentSlot.weapon
        ? Random().nextInt(10) + 1
        : 0;
    final statModifier =
        generateRandomTestStatModifier(equipmentId, equipmentType.slot);
    return Equipment(
      id: equipmentId,
      characterId: character.id,
      isEquipped: false,
      rarity: Rarity.uncommon,
      type: equipmentType,
      tier: 1,
      attackPower: attackPower,
      actionPointCost: equipmentType.actionPointCost,
      damageType: DamageType.physical,
      armorValue: armorValue,
      statModifiers: [statModifier],
    );
  }

  StatModifier generateRandomTestStatModifier(
      String equipmentId, EquipmentSlot equipmentSlot) {
    final availableStatModifierTypes =
        StatModifierType.availableStatModifierTypes(equipmentSlot);
    final statModifierType = availableStatModifierTypes[
        Random().nextInt(availableStatModifierTypes.length)];
    final statModifier = StatModifier(
      id: Uuid().v4(),
      equipmentId: equipmentId,
      type: statModifierType,
      location: StatModifierLocation.equipment,
      tier: 1,
    );
    return statModifier;
  }
}
