import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_combat_stats.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/stat_modifier.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:sqflite/sqflite.dart';

class CombatService {
  final Database db;
  late CharacterRepository characterRepository;
  late EquipmentRepository equipmentRepository;

  CombatService({required this.db}) {
    characterRepository = CharacterRepository(db: db);
    equipmentRepository = EquipmentRepository(db: db);
  }

  Future<CharacterCombatStats> getCharacterCombatStats(
      Character character) async {
    final equipment = await equipmentRepository
        .getEquippedEquipmentByCharacterId(character.id);
    final modifiers = equipment.fold<List<StatModifier>>(
        [], (list, equipment) => [...list, ...equipment.statModifiers]);

    // TODO : Decide on base values
    final baseStatusEffectChance = 0.05;
    final baseResourceRegenRate = 10;
    final baseFlaskHealPercentage = 0.2;
    //

    int baseAttackPower = 0;
    final weaponEquipments = equipment
        .where((equipment) => equipment.type.slot == EquipmentSlot.weapon);
    DamageType basicAttackDamageType = DamageType.physical;
    if (weaponEquipments.isNotEmpty) {
      baseAttackPower = weaponEquipments.first.attackPower;
      basicAttackDamageType = weaponEquipments.first.damageType;
    }

    double physicalDamageMultiplier = 1;
    double fireDamageMultiplier = 1;
    double iceDamageMultiplier = 1;
    double poisonDamageMultiplier = 1;
    double critChance = 0;
    double critDamageMultiplier = 1;
    double lifeSteal = 1;
    double apCostReduction = 0;
    double statusEffectChance = baseStatusEffectChance;
    double statusEffectDurationMultiplier = 1;
    int armor = 0;
    int maxHealth = character.maxHealth;
    int maxResource = character.maxMana;
    double cooldownReduction = 0;
    int resourceRegenRate = baseResourceRegenRate;
    double flaskHealPercentage = baseFlaskHealPercentage;
    double damageReflection = 0;
    double blockChance = 0;
    double expGainMultiplier = 1;
    double goldGainMultiplier = 1;
    bool fireImmunity = false;
    bool iceImmunity = false;
    bool poisonImmunity = false;

    for (var modifier in modifiers) {
      switch (modifier.type) {
        case StatModifierType.attackPower:
          baseAttackPower += modifier.type.tierValue(modifier.tier).toInt();
          break;
        case StatModifierType.physicalDamage:
          physicalDamageMultiplier += modifier.type.tierValue(modifier.tier);
          break;
        case StatModifierType.fireDamage:
          fireDamageMultiplier += modifier.type.tierValue(modifier.tier);
          break;
        case StatModifierType.iceDamage:
          iceDamageMultiplier += modifier.type.tierValue(modifier.tier);
          break;
        case StatModifierType.poisonDamage:
          poisonDamageMultiplier += modifier.type.tierValue(modifier.tier);
          break;
        case StatModifierType.critChance:
          critChance += modifier.type.tierValue(modifier.tier);
          break;
        case StatModifierType.critDamage:
          critDamageMultiplier += modifier.type.tierValue(modifier.tier);
          break;
        case StatModifierType.lifeSteal:
          lifeSteal += modifier.type.tierValue(modifier.tier);
          break;
        case StatModifierType.apEfficiency:
          apCostReduction += modifier.type.tierValue(modifier.tier);
          break;
        case StatModifierType.statusEffectChance:
          statusEffectChance += modifier.type.tierValue(modifier.tier);
          break;
        case StatModifierType.statusEffectDuration:
          statusEffectDurationMultiplier +=
              modifier.type.tierValue(modifier.tier);
          break;
        case StatModifierType.armor:
          armor += modifier.type.tierValue(modifier.tier).toInt();
          break;
        case StatModifierType.health:
          maxHealth += modifier.type.tierValue(modifier.tier).toInt();
          break;
        case StatModifierType.resourceRegen:
          resourceRegenRate += modifier.type.tierValue(modifier.tier).toInt();
          break;
        case StatModifierType.flaskPotency:
          flaskHealPercentage += modifier.type.tierValue(modifier.tier);
          break;
        case StatModifierType.damageReflection:
          damageReflection += modifier.type.tierValue(modifier.tier);
          break;
        case StatModifierType.blockChance:
          blockChance += modifier.type.tierValue(modifier.tier);
          break;
        case StatModifierType.expGain:
          expGainMultiplier += modifier.type.tierValue(modifier.tier);
          break;
        case StatModifierType.goldGain:
          goldGainMultiplier += modifier.type.tierValue(modifier.tier);
          break;
        case StatModifierType.fireImmunity:
          fireImmunity = true;
          break;
        case StatModifierType.iceImmunity:
          iceImmunity = true;
          break;
        case StatModifierType.poisonImmunity:
          poisonImmunity = true;
          break;
        default:
          break;
      }
    }

    return CharacterCombatStats(
      basicAttackDamageType: basicAttackDamageType,
      physicalBaseDamage: (baseAttackPower * physicalDamageMultiplier).round(),
      fireBaseDamage: (baseAttackPower * fireDamageMultiplier).round(),
      iceBaseDamage: (baseAttackPower * iceDamageMultiplier).round(),
      poisonBaseDamage: (baseAttackPower * poisonDamageMultiplier).round(),
      critChance: critChance,
      critDamageMultiplier: critDamageMultiplier,
      lifeSteal: lifeSteal,
      apCostReduction: apCostReduction,
      statusEffectChance: statusEffectChance,
      statusEffectDuration: statusEffectDurationMultiplier,
      armor: armor,
      maxHealth: maxHealth,
      maxResource: maxResource,
      cooldown: cooldownReduction,
      resourceRegenRate: resourceRegenRate,
      flaskHealPercentage: flaskHealPercentage,
      damageReflection: damageReflection,
      blockChance: blockChance,
      expGain: expGainMultiplier,
      goldGain: goldGainMultiplier,
      fireImmunity: fireImmunity,
      iceImmunity: iceImmunity,
      poisonImmunity: poisonImmunity,
    );
  }
}
