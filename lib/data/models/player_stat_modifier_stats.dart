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

  // Equipment and equipped passive skills both feed this same accumulator
  // (Skill System Foundations ticket, subtask 5) — the only difference is
  // which tier-value formula prices a given StatModifier's contribution:
  // equipment-sourced ones scale by the item's own tier
  // (equipmentTierValue), passive-sourced ones by the skill's level
  // (skillTierValue, via the StatModifier's own `tier` field — see
  // BasePassiveSkill.statModifiers). passiveModifiers defaults to empty so
  // every existing non-passive call site is unaffected.
  static PlayerStatModifierStats fromStatModifiers(
    List<Equipment> equipments, {
    List<StatModifier> passiveModifiers = const [],
  }) {
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

    // One accumulation switch shared by both sources below — each source
    // resolves its own `value` (equipmentTierValue vs skillTierValue)
    // before calling in, so this only ever deals with "how does this
    // StatModifierType affect the totals", not where the number came from.
    void accumulate(StatModifierType type, double value) {
      switch (type) {
        case StatModifierType.attackPower:
          baseAttackPower += value;
          break;
        case StatModifierType.physicalDamage:
          physicalDamageMultiplier += value;
          break;
        case StatModifierType.fireDamage:
          fireDamageMultiplier += value;
          break;
        case StatModifierType.iceDamage:
          iceDamageMultiplier += value;
          break;
        case StatModifierType.poisonDamage:
          poisonDamageMultiplier += value;
          break;
        case StatModifierType.critChance:
          additionalCritChancePercentage += value;
          break;
        case StatModifierType.critDamage:
          additionalCritDamagePercentage += value;
          break;
        case StatModifierType.lifeSteal:
          lifeStealPercentage += value;
          break;
        case StatModifierType.apEfficiency:
          apEfficiencyMultiplier += value;
          break;
        case StatModifierType.statusEffectChance:
          additionalStatusEffectChancePercentage += value;
          break;
        case StatModifierType.statusEffectDuration:
          additionalStatusEffectDurationMultiplier += value;
          break;
        case StatModifierType.armor:
          baseArmor += value;
          break;
        case StatModifierType.health:
          additionalHealth += value;
          break;
        case StatModifierType.cooldown:
          cooldownReductionPercentage += value;
          break;
        case StatModifierType.resourceRegen:
          additionalResourceRegen += value;
          break;
        case StatModifierType.flaskPotency:
          additionalFlaskPotencyPercentage += value;
          break;
        case StatModifierType.damageReflection:
          damageReflectionPercentage += value;
          break;
        case StatModifierType.blockChance:
          blockChancePercentage += value;
          break;
        case StatModifierType.expGain:
          expGainMultiplier += value;
          break;
        case StatModifierType.goldGain:
          goldGainMultiplier += value;
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
          additionalMotePotencyPercentage += value;
          break;
      }
    }

    for (var equipment in equipments) {
      for (var statModifier in equipment.statModifiers) {
        accumulate(statModifier.type,
            statModifier.type.equipmentTierValue(equipment.tier));
      }
    }
    for (var statModifier in passiveModifiers) {
      accumulate(
          statModifier.type, statModifier.type.skillTierValue(statModifier.tier));
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
