import 'package:questvale/helpers/shared_enums.dart';

class CharacterCombatStats {
  final DamageType basicAttackDamageType;
  final int physicalBaseDamage;
  final int fireBaseDamage;
  final int iceBaseDamage;
  final int poisonBaseDamage;
  final double critChance;
  final double critDamageMultiplier;
  final double lifeSteal;
  final double apCostReduction;
  final double statusEffectChance;
  final double statusEffectDuration;
  final int armor;
  final int maxHealth;
  final int maxResource;
  final double cooldown;
  final int resourceRegenRate;
  final double flaskHealPercentage;
  final double damageReflection;
  final double blockChance;
  final double expGain;
  final double goldGain;
  final bool fireImmunity;
  final bool iceImmunity;
  final bool poisonImmunity;

  CharacterCombatStats({
    required this.basicAttackDamageType,
    required this.physicalBaseDamage,
    required this.fireBaseDamage,
    required this.iceBaseDamage,
    required this.poisonBaseDamage,
    required this.critChance,
    required this.critDamageMultiplier,
    required this.lifeSteal,
    required this.apCostReduction,
    required this.statusEffectChance,
    required this.statusEffectDuration,
    required this.armor,
    required this.maxHealth,
    required this.maxResource,
    required this.cooldown,
    required this.resourceRegenRate,
    required this.flaskHealPercentage,
    required this.damageReflection,
    required this.blockChance,
    required this.expGain,
    required this.goldGain,
    required this.fireImmunity,
    required this.iceImmunity,
    required this.poisonImmunity,
  });

  CharacterCombatStats copyWith({
    DamageType? basicAttackDamageType,
    int? physicalBaseDamage,
    int? fireBaseDamage,
    int? iceBaseDamage,
    int? poisonBaseDamage,
    double? critChance,
    double? critDamageMultiplier,
    double? lifeSteal,
    double? apCostReduction,
    double? statusEffectChance,
    double? statusEffectDuration,
    int? armor,
    int? masHealth,
    int? maxResource,
    double? cooldown,
    int? resourceRegenRate,
    double? flaskHealPercentage,
    double? damageReflection,
    double? blockChance,
    double? expGain,
    double? goldGain,
    bool? fireImmunity,
    bool? iceImmunity,
    bool? poisonImmunity,
  }) {
    return CharacterCombatStats(
      basicAttackDamageType:
          basicAttackDamageType ?? this.basicAttackDamageType,
      physicalBaseDamage: physicalBaseDamage ?? this.physicalBaseDamage,
      fireBaseDamage: fireBaseDamage ?? this.fireBaseDamage,
      iceBaseDamage: iceBaseDamage ?? this.iceBaseDamage,
      poisonBaseDamage: poisonBaseDamage ?? this.poisonBaseDamage,
      critChance: critChance ?? this.critChance,
      critDamageMultiplier: critDamageMultiplier ?? this.critDamageMultiplier,
      lifeSteal: lifeSteal ?? this.lifeSteal,
      apCostReduction: apCostReduction ?? this.apCostReduction,
      statusEffectChance: statusEffectChance ?? this.statusEffectChance,
      statusEffectDuration: statusEffectDuration ?? this.statusEffectDuration,
      armor: armor ?? this.armor,
      maxHealth: masHealth ?? this.maxHealth,
      maxResource: maxResource ?? this.maxResource,
      cooldown: cooldown ?? this.cooldown,
      resourceRegenRate: resourceRegenRate ?? this.resourceRegenRate,
      flaskHealPercentage: flaskHealPercentage ?? this.flaskHealPercentage,
      damageReflection: damageReflection ?? this.damageReflection,
      blockChance: blockChance ?? this.blockChance,
      expGain: expGain ?? this.expGain,
      goldGain: goldGain ?? this.goldGain,
      fireImmunity: fireImmunity ?? this.fireImmunity,
      iceImmunity: iceImmunity ?? this.iceImmunity,
      poisonImmunity: poisonImmunity ?? this.poisonImmunity,
    );
  }

  @override
  String toString() {
    return 'CharacterCombatStats(basicAttackDamageType: $basicAttackDamageType, physicalBaseDamage: $physicalBaseDamage, fireBaseDamage: $fireBaseDamage, iceBaseDamage: $iceBaseDamage, poisonBaseDamage: $poisonBaseDamage, critChance: $critChance, critDamageMultiplier: $critDamageMultiplier, lifeSteal: $lifeSteal, apCostReduction: $apCostReduction, statusEffectChance: $statusEffectChance, statusEffectDuration: $statusEffectDuration, armor: $armor, masHealth: $maxHealth, maxResource: $maxResource, cooldown: $cooldown, resourceRegenRate: $resourceRegenRate, flaskHealPercentage: $flaskHealPercentage, damageReflection: $damageReflection, blockChance: $blockChance, expGain: $expGain, goldGain: $goldGain, fireImmunity: $fireImmunity, iceImmunity: $iceImmunity, poisonImmunity: $poisonImmunity)';
  }
}
