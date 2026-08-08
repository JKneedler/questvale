import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/models/stat_modifier.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/helpers/shared_enums.dart';

Equipment _weapon({
  required DamageType damageType,
  EquipmentType type = EquipmentType.wandAndFocus,
  List<StatModifier> statModifiers = const [],
}) {
  return Equipment(
    id: 'weapon-1',
    characterId: 'character-1',
    rarity: Rarity.common,
    type: type,
    tier: 1,
    attackPower: 0,
    damageType: damageType,
    armorValue: 0,
    statModifiers: statModifiers,
  );
}

Equipment _attackPowerGear({double tierValue = 4}) {
  // attackPower's equipmentTierValue is flat (tier * 4), so tier 1 gives a
  // clean +4 baseAttackPower to build the expected numbers off of below.
  return Equipment(
    id: 'weapon-1',
    characterId: 'character-1',
    rarity: Rarity.common,
    type: EquipmentType.wandAndFocus,
    tier: 1,
    attackPower: 0,
    damageType: DamageType.fire,
    armorValue: 0,
    statModifiers: const [
      StatModifier(
        id: 'mod-1',
        location: StatModifierLocation.equipment,
        equipmentId: 'weapon-1',
        type: StatModifierType.attackPower,
        tier: 1,
      ),
    ],
  );
}

void main() {
  group('weaponDamageType', () {
    test('picks up the equipped weapon\'s DamageType', () {
      final stats = PlayerCombatStats(
          playerLevel: 1,
          characterClass: CharacterClass.mage,
          equipments: [_weapon(damageType: DamageType.ice)]);
      expect(stats.weaponDamageType, DamageType.ice);
    });

    test('defaults to physical when nothing is equipped in the weapon slot',
        () {
      final stats = PlayerCombatStats(
          playerLevel: 1, characterClass: CharacterClass.mage, equipments: []);
      expect(stats.weaponDamageType, DamageType.physical);
    });

    test('ignores non-weapon equipment when looking for the weapon slot', () {
      final helmet = Equipment(
        id: 'helmet-1',
        characterId: 'character-1',
        rarity: Rarity.common,
        type: EquipmentType.helmet,
        tier: 1,
        attackPower: 0,
        damageType: DamageType.poison,
        armorValue: 4,
        statModifiers: const [],
      );
      final stats = PlayerCombatStats(
          playerLevel: 1,
          characterClass: CharacterClass.mage,
          equipments: [helmet]);
      expect(stats.weaponDamageType, DamageType.physical);
    });
  });

  group('attackPowerFor', () {
    test('physical/fire/ice/poison each read their own matching getter', () {
      final stats = PlayerCombatStats(
          playerLevel: 1,
          characterClass: CharacterClass.mage,
          equipments: [_attackPowerGear()]);
      expect(stats.attackPowerFor(SkillDamageType.physical),
          stats.physicalAttackPower);
      expect(
          stats.attackPowerFor(SkillDamageType.fire), stats.fireAttackPower);
      expect(stats.attackPowerFor(SkillDamageType.ice), stats.iceAttackPower);
      expect(stats.attackPowerFor(SkillDamageType.poison),
          stats.poisonAttackPower);
    });

    test('weaponType defers to the equipped weapon\'s own DamageType', () {
      final stats = PlayerCombatStats(
          playerLevel: 1,
          characterClass: CharacterClass.mage,
          equipments: [
            _weapon(damageType: DamageType.ice, statModifiers: [
              const StatModifier(
                id: 'mod-1',
                location: StatModifierLocation.equipment,
                equipmentId: 'weapon-1',
                type: StatModifierType.attackPower,
                tier: 1,
              ),
              // Also roll an iceDamage multiplier so iceAttackPower actually
              // diverges numerically from physicalAttackPower below — without
              // this, both read the same baseAttackPower with a 0 multiplier
              // and the two getters coincidentally match by value even if
              // weaponType resolved to the wrong one.
              const StatModifier(
                id: 'mod-2',
                location: StatModifierLocation.equipment,
                equipmentId: 'weapon-1',
                type: StatModifierType.iceDamage,
                tier: 1,
              ),
            ])
          ]);
      expect(
          stats.attackPowerFor(SkillDamageType.weaponType), stats.iceAttackPower);
      expect(stats.attackPowerFor(SkillDamageType.weaponType),
          isNot(stats.physicalAttackPower));
    });

    test('weaponType falls back to physical for an ungeared character', () {
      final stats = PlayerCombatStats(
          playerLevel: 1, characterClass: CharacterClass.mage, equipments: []);
      expect(stats.attackPowerFor(SkillDamageType.weaponType), 0);
      expect(stats.attackPowerFor(SkillDamageType.weaponType),
          stats.physicalAttackPower);
    });
  });

  group('maxHealth', () {
    test('sums class base + level term + gear\'s additionalHealth', () {
      final equipment = Equipment(
        id: 'chest-1',
        characterId: 'character-1',
        rarity: Rarity.common,
        type: EquipmentType.chestplate,
        tier: 2,
        attackPower: 0,
        damageType: DamageType.physical,
        armorValue: 0,
        statModifiers: const [
          StatModifier(
            id: 'mod-1',
            location: StatModifierLocation.equipment,
            equipmentId: 'chest-1',
            type: StatModifierType.health,
            tier: 2,
          ),
        ],
      );
      final stats = PlayerCombatStats(
          playerLevel: 10,
          characterClass: CharacterClass.mage,
          equipments: [equipment]);
      // baseMaxHealth(mage)=60 + 10*10 + health tier-2 (tier*10=20) = 180.
      expect(stats.maxHealth, 180);
    });

    test('differs by class at the same level with no gear', () {
      final warrior = PlayerCombatStats(
          playerLevel: 1, characterClass: CharacterClass.warrior, equipments: []);
      final mage = PlayerCombatStats(
          playerLevel: 1, characterClass: CharacterClass.mage, equipments: []);
      expect(warrior.maxHealth, isNot(mage.maxHealth));
    });
  });
}
