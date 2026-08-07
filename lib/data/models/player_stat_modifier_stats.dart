import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/stat_modifier.dart';

class PlayerStatModifierStats {
  final double baseAttackPower;
  final double physicalDamageMultiplier;
  final double fireDamageMultiplier;
  final double iceDamageMultiplier;
  final double poisonDamageMultiplier;
  final double additionalCritChancePercentage;
  final double additionalCritDamagePercentage;
  final double lifeStealPercentage;
  final double apEfficiencyMultiplier;
  final double additionalStatusEffectChancePercentage;
  final double additionalStatusEffectDurationMultiplier;
  final double baseArmor;
  final double additionalHealth;
  final double cooldownReductionPercentage;
  final double additionalResourceRegen;
  final double additionalFlaskPotencyPercentage;
  final double damageReflectionPercentage;
  final double blockChancePercentage;
  final double expGainMultiplier;
  final double goldGainMultiplier;
  final bool isFireImmune;
  final bool isIceImmune;
  final bool isPoisonImmune;
  final double additionalMotePotencyPercentage;

  PlayerStatModifierStats({
    required this.baseAttackPower,
    required this.physicalDamageMultiplier,
    required this.fireDamageMultiplier,
    required this.iceDamageMultiplier,
    required this.poisonDamageMultiplier,
    required this.additionalCritChancePercentage,
    required this.additionalCritDamagePercentage,
    required this.lifeStealPercentage,
    required this.apEfficiencyMultiplier,
    required this.additionalStatusEffectChancePercentage,
    required this.additionalStatusEffectDurationMultiplier,
    required this.baseArmor,
    required this.additionalHealth,
    required this.cooldownReductionPercentage,
    required this.additionalResourceRegen,
    required this.additionalFlaskPotencyPercentage,
    required this.damageReflectionPercentage,
    required this.blockChancePercentage,
    required this.expGainMultiplier,
    required this.goldGainMultiplier,
    required this.isFireImmune,
    required this.isIceImmune,
    required this.isPoisonImmune,
    required this.additionalMotePotencyPercentage,
  });

  // Include an additional parameter for stat modifiers from passive skills (BasePassiveSkill)
  static PlayerStatModifierStats fromStatModifiers(List<Equipment> equipments) {
    double baseAttackPower = 0;
    double physicalDamageMultiplier = 0;
    double fireDamageMultiplier = 0;
    double iceDamageMultiplier = 0;
    double poisonDamageMultiplier = 0;
    double additionalCritChancePercentage = 0;
    double additionalCritDamagePercentage = 0;
    double lifeStealPercentage = 0;
    double apEfficiencyMultiplier = 0;
    double additionalStatusEffectChancePercentage = 0;
    double additionalStatusEffectDurationMultiplier = 0;
    double baseArmor = 0;
    double additionalHealth = 0;
    double cooldownReductionPercentage = 0;
    double additionalResourceRegen = 0;
    double additionalFlaskPotencyPercentage = 0;
    double damageReflectionPercentage = 0;
    double blockChancePercentage = 0;
    double expGainMultiplier = 0;
    double goldGainMultiplier = 0;
    bool isFireImmune = false;
    bool isIceImmune = false;
    bool isPoisonImmune = false;
    double additionalMotePotencyPercentage = 0;

    for (var equipment in equipments) {
      for (var statModifier in equipment.statModifiers) {
        switch (statModifier.type) {
          case StatModifierType.attackPower:
            baseAttackPower +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.physicalDamage:
            physicalDamageMultiplier +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.fireDamage:
            fireDamageMultiplier +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.iceDamage:
            iceDamageMultiplier +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.poisonDamage:
            poisonDamageMultiplier +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.critChance:
            additionalCritChancePercentage +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.critDamage:
            additionalCritDamagePercentage +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.lifeSteal:
            lifeStealPercentage +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.apEfficiency:
            apEfficiencyMultiplier +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.statusEffectChance:
            additionalStatusEffectChancePercentage +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.statusEffectDuration:
            additionalStatusEffectDurationMultiplier +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.armor:
            baseArmor += statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.health:
            additionalHealth +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.cooldown:
            cooldownReductionPercentage +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.resourceRegen:
            additionalResourceRegen +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.flaskPotency:
            additionalFlaskPotencyPercentage +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.damageReflection:
            damageReflectionPercentage +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.blockChance:
            blockChancePercentage +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.expGain:
            expGainMultiplier +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.goldGain:
            goldGainMultiplier +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          case StatModifierType.fireImmunity:
            isFireImmune = true;
            break;
          case StatModifierType.iceImmunity:
            isIceImmune = true;
            break;
          case StatModifierType.poisonImmunity:
            isPoisonImmune = true;
            break;
          case StatModifierType.motePotency:
            additionalMotePotencyPercentage +=
                statModifier.type.equipmentTierValue(equipment.tier);
            break;
          default:
            break;
        }
      }
    }

    return PlayerStatModifierStats(
      baseAttackPower: baseAttackPower,
      physicalDamageMultiplier: physicalDamageMultiplier,
      fireDamageMultiplier: fireDamageMultiplier,
      iceDamageMultiplier: iceDamageMultiplier,
      poisonDamageMultiplier: poisonDamageMultiplier,
      additionalCritChancePercentage: additionalCritChancePercentage,
      additionalCritDamagePercentage: additionalCritDamagePercentage,
      lifeStealPercentage: lifeStealPercentage,
      apEfficiencyMultiplier: apEfficiencyMultiplier,
      additionalStatusEffectChancePercentage:
          additionalStatusEffectChancePercentage,
      additionalStatusEffectDurationMultiplier:
          additionalStatusEffectDurationMultiplier,
      baseArmor: baseArmor,
      additionalHealth: additionalHealth,
      cooldownReductionPercentage: cooldownReductionPercentage,
      additionalResourceRegen: additionalResourceRegen,
      additionalFlaskPotencyPercentage: additionalFlaskPotencyPercentage,
      damageReflectionPercentage: damageReflectionPercentage,
      blockChancePercentage: blockChancePercentage,
      expGainMultiplier: expGainMultiplier,
      goldGainMultiplier: goldGainMultiplier,
      isFireImmune: isFireImmune,
      isIceImmune: isIceImmune,
      isPoisonImmune: isPoisonImmune,
      additionalMotePotencyPercentage: additionalMotePotencyPercentage,
    );
  }
}
