import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/models/stat_modifier.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/services/equipment_service.dart';

Character _character(CharacterClass characterClass) {
  return Character(
    id: 'character-1',
    name: 'Test',
    characterClass: characterClass,
    level: 1,
    gold: 0,
    currentExp: 0,
    currentHealth: 10,
    actionPoints: 0,
  );
}

void main() {
  group('generateStarterWeapon', () {
    test('picks each class\'s primary weapon type', () {
      expect(EquipmentService.generateStarterWeapon(_character(CharacterClass.warrior)).type,
          EquipmentType.swordAndShield);
      expect(EquipmentService.generateStarterWeapon(_character(CharacterClass.rogue)).type,
          EquipmentType.daggers);
      expect(EquipmentService.generateStarterWeapon(_character(CharacterClass.mage)).type,
          EquipmentType.wandAndFocus);
    });

    test('always carries a guaranteed attackPower StatModifier — not a random pick', () {
      final weapon =
          EquipmentService.generateStarterWeapon(_character(CharacterClass.mage));
      expect(weapon.statModifiers.length, 1);
      expect(weapon.statModifiers.single.type, StatModifierType.attackPower);
    });

    test('the resulting weapon gives a character non-zero attack power', () {
      final character = _character(CharacterClass.mage);
      final weapon = EquipmentService.generateStarterWeapon(character);
      final stats =
          PlayerCombatStats(playerLevel: character.level, equipments: [weapon]);
      expect(stats.physicalAttackPower, greaterThan(0));
    });

    test('is deterministic, not randomized, across repeated calls', () {
      final character = _character(CharacterClass.warrior);
      final a = EquipmentService.generateStarterWeapon(character);
      final b = EquipmentService.generateStarterWeapon(character);
      expect(a.type, b.type);
      expect(a.rarity, b.rarity);
      expect(a.tier, b.tier);
      expect(a.statModifiers.single.type, b.statModifiers.single.type);
    });
  });
}
