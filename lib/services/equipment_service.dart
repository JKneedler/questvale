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

  // A deterministic tier-1 weapon (not randomized like
  // generateRandomTestEquipment) carrying a guaranteed attackPower
  // StatModifier, for admin actions that need a character to be able to
  // deal real damage right away (see the Skill System Foundations ticket,
  // subtask 2) — an unequipped character now has 0 base attack power and
  // so deals 0 damage, which admin actions like "reset character" and
  // "delete all equipment" would otherwise leave them stuck at.
  // generateRandomTestEquipment's random type/stat pick isn't good enough
  // here: it can land on a non-weapon slot or a stat modifier that isn't
  // attackPower at all, still leaving damage at 0.
  //
  // Pure — no DB — so it's static (matching this codebase's convention for
  // pure logic, e.g. CombatService.computeRawDamage) and unit testable on
  // its own (see equipment_service_test.dart).
  static Equipment generateStarterWeapon(Character character) {
    final weaponType = EquipmentType.availableEquipmentTypes(
            character.characterClass)
        .firstWhere((type) => type.slot == EquipmentSlot.weapon);
    final equipmentId = Uuid().v4();
    return Equipment(
      id: equipmentId,
      characterId: character.id,
      rarity: Rarity.common,
      type: weaponType,
      tier: 1,
      attackPower: 0,
      damageType: DamageType.physical,
      armorValue: 0,
      statModifiers: [
        StatModifier(
          id: Uuid().v4(),
          equipmentId: equipmentId,
          type: StatModifierType.attackPower,
          location: StatModifierLocation.equipment,
          tier: 1,
        ),
      ],
    );
  }

  Equipment generateEquipment(
      Character character, QuestZone questZone, EncounterType encounterType) {
    return Equipment(
      id: Uuid().v4(),
      characterId: character.id,
      rarity: Rarity.common,
      type: EquipmentType.swordAndShield,
      tier: 1,
      attackPower: 10,
      damageType: DamageType.physical,
      armorValue: 10,
      statModifiers: [],
    );
  }

  Future<void> upgradeEquipment(
      Equipment equipment, CharacterClass characterClass) async {
    final newStatModifier = generateRandomTestStatModifier(
        equipment.id, equipment.type.slot, characterClass);
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
    final statModifier = generateRandomTestStatModifier(
        equipmentId, equipmentType.slot, character.characterClass);
    return Equipment(
      id: equipmentId,
      characterId: character.id,
      rarity: Rarity.uncommon,
      type: equipmentType,
      tier: 1,
      attackPower: attackPower,
      damageType: DamageType.physical,
      armorValue: armorValue,
      statModifiers: [statModifier],
    );
  }

  StatModifier generateRandomTestStatModifier(String equipmentId,
      EquipmentSlot equipmentSlot, CharacterClass characterClass) {
    final availableStatModifierTypes = StatModifierType
        .availableStatModifierTypes(equipmentSlot, characterClass);
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
