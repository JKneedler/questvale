import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/models/player_stat_modifier_stats.dart';
import 'package:questvale/data/models/stat_modifier.dart';
import 'package:questvale/helpers/shared_enums.dart';

void main() {
  group('motePotency — class + slot gating', () {
    test('rollable on weapon and hands for a Mage', () {
      expect(
          StatModifierType.availableStatModifierTypes(
              EquipmentSlot.weapon, CharacterClass.mage),
          contains(StatModifierType.motePotency));
      expect(
          StatModifierType.availableStatModifierTypes(
              EquipmentSlot.hands, CharacterClass.mage),
          contains(StatModifierType.motePotency));
    });

    test('not offered on the same slots for Warrior/Rogue — class-gated, not just slot-gated', () {
      for (final characterClass in [CharacterClass.warrior, CharacterClass.rogue]) {
        for (final slot in [EquipmentSlot.weapon, EquipmentSlot.hands]) {
          expect(
              StatModifierType.availableStatModifierTypes(slot, characterClass),
              isNot(contains(StatModifierType.motePotency)),
              reason: '$characterClass should never roll motePotency on $slot');
        }
      }
    });

    test('not offered on slots that never rolled attackPower either, even for a Mage', () {
      for (final slot in [
        EquipmentSlot.head,
        EquipmentSlot.body,
        EquipmentSlot.feet,
        EquipmentSlot.neck,
        EquipmentSlot.ring,
      ]) {
        expect(
            StatModifierType.availableStatModifierTypes(
                slot, CharacterClass.mage),
            isNot(contains(StatModifierType.motePotency)),
            reason: '$slot should not roll motePotency regardless of class');
      }
    });

    test('classRestriction is null for every type not explicitly gated', () {
      const gated = {
        StatModifierType.motePotency,
        StatModifierType.fireDamage,
        StatModifierType.iceDamage,
      };
      for (final type in StatModifierType.values) {
        if (gated.contains(type)) continue;
        expect(type.classRestriction, isNull,
            reason: '$type should stay universal unless deliberately gated');
      }
    });

    test('a universal stat (attackPower) is unaffected by class-gating', () {
      for (final characterClass in CharacterClass.values) {
        expect(
            StatModifierType.availableStatModifierTypes(
                EquipmentSlot.weapon, characterClass),
            contains(StatModifierType.attackPower));
      }
    });
  });

  group('fireDamage/iceDamage — Mage-exclusive', () {
    test('rollable for a Mage on every slot that already offered them', () {
      for (final slot in [
        EquipmentSlot.weapon,
        EquipmentSlot.hands,
        EquipmentSlot.neck,
        EquipmentSlot.ring,
      ]) {
        final types = StatModifierType.availableStatModifierTypes(
            slot, CharacterClass.mage);
        expect(types, contains(StatModifierType.fireDamage));
        expect(types, contains(StatModifierType.iceDamage));
      }
    });

    test('absent for Warrior/Rogue on those same slots', () {
      for (final characterClass in [CharacterClass.warrior, CharacterClass.rogue]) {
        for (final slot in [
          EquipmentSlot.weapon,
          EquipmentSlot.hands,
          EquipmentSlot.neck,
          EquipmentSlot.ring,
        ]) {
          final types =
              StatModifierType.availableStatModifierTypes(slot, characterClass);
          expect(types, isNot(contains(StatModifierType.fireDamage)),
              reason: '$characterClass should never roll fireDamage on $slot');
          expect(types, isNot(contains(StatModifierType.iceDamage)),
              reason: '$characterClass should never roll iceDamage on $slot');
        }
      }
    });

    test('physicalDamage and poisonDamage stay universal (only fire/ice were gated)', () {
      for (final characterClass in [CharacterClass.warrior, CharacterClass.rogue]) {
        final types = StatModifierType.availableStatModifierTypes(
            EquipmentSlot.weapon, characterClass);
        expect(types, contains(StatModifierType.physicalDamage));
        expect(types, contains(StatModifierType.poisonDamage));
      }
    });
  });

  group('motePotency — value formatting', () {
    test('scales linearly with tier, same formula as the elemental damage% stats', () {
      expect(StatModifierType.motePotency.equipmentTierValue(1), 0.05);
      expect(StatModifierType.motePotency.equipmentTierValue(3), closeTo(0.15, 1e-9));
    });

    test('is treated as a percentage stat', () {
      expect(StatModifierType.motePotency.isPercentage(), isTrue);
    });

    test('has the expected display name', () {
      expect(StatModifierType.motePotency.displayName, 'Mote Potency');
    });
  });

  test('accumulates into PlayerStatModifierStats and PlayerCombatStats', () {
    final equipment = Equipment(
      id: 'eq-1',
      characterId: 'char-1',
      rarity: Rarity.common,
      type: EquipmentType.wandAndFocus,
      tier: 2,
      attackPower: 0,
      damageType: DamageType.physical,
      armorValue: 0,
      statModifiers: [
        const StatModifier(
          id: 'mod-1',
          location: StatModifierLocation.equipment,
          equipmentId: 'eq-1',
          type: StatModifierType.motePotency,
          tier: 1,
        ),
      ],
    );

    final stats = PlayerStatModifierStats.fromStatModifiers([equipment]);
    // tier used for the value lookup is the equipment's own tier (2), not
    // the modifier row's tier (1) — matches every other stat's accumulation
    // in fromStatModifiers.
    expect(stats.additionalMotePotencyPercentage, closeTo(0.1, 1e-9));

    final combatStats =
        PlayerCombatStats(playerLevel: 1, equipments: [equipment]);
    expect(combatStats.motePotency, closeTo(0.1, 1e-9));
  });
}
