import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/player_stat_modifier_stats.dart';
import 'package:questvale/helpers/constants.dart';

class PlayerCombatStats {
  late PlayerStatModifierStats statModifierStats;
  final int playerLevel;
  // List<StatusEffect> activeStatusEffects;

  PlayerCombatStats({
    required this.playerLevel,
    required List<Equipment> equipments,
  }) {
    statModifierStats = PlayerStatModifierStats.fromStatModifiers(equipments);
  }

  get physicalAttackPower =>
      statModifierStats.baseAttackPower *
      (1 + statModifierStats.physicalDamageMultiplier);
  get fireAttackPower =>
      statModifierStats.baseAttackPower *
      (1 + statModifierStats.fireDamageMultiplier);
  get iceAttackPower =>
      statModifierStats.baseAttackPower *
      (1 + statModifierStats.iceDamageMultiplier);
  get poisonAttackPower =>
      statModifierStats.baseAttackPower *
      (1 + statModifierStats.poisonDamageMultiplier);
  get critChance =>
      BASE_CRIT_CHANCE + statModifierStats.additionalCritChancePercentage;
  get critDamage =>
      BASE_CRIT_DAMAGE_MULTIPLIER +
      statModifierStats.additionalCritDamagePercentage;
  get lifeSteal => statModifierStats.lifeStealPercentage;
  get apEfficiency => statModifierStats.apEfficiencyMultiplier;
  get statusEffectChance =>
      BASE_STATUS_EFFECT_CHANCE +
      statModifierStats.additionalStatusEffectChancePercentage;
  get statusEffectDurationMultiplier =>
      1 + statModifierStats.additionalStatusEffectDurationMultiplier;
  get armor => statModifierStats.baseArmor;
  get maxHealth =>
      BASE_HEALTH +
      (BASE_HEALTH_PER_LEVEL * playerLevel) +
      statModifierStats.additionalHealth;
  get cooldownMultiplier => 1 - statModifierStats.cooldownReductionPercentage;
  get resourceRegen =>
      BASE_RESOURCE_REGEN +
      (BASE_RESOURCE_REGEN_PER_LEVEL * playerLevel) +
      statModifierStats.additionalResourceRegen;
  get additionalFlaskPotencyPercentage =>
      statModifierStats.additionalFlaskPotencyPercentage;
  get damageReflection => statModifierStats.damageReflectionPercentage;
  get blockChance => statModifierStats.blockChancePercentage;
  get expGainMultiplier => 1 + statModifierStats.expGainMultiplier;
  get goldGainMultiplier => 1 + statModifierStats.goldGainMultiplier;
  get fireImmunity => statModifierStats.isFireImmune;
  get iceImmunity => statModifierStats.isIceImmune;
  get poisonImmunity => statModifierStats.isPoisonImmune;
  // Bonus effect from consumed Motes (Ember Burst/Hoarfrost Burst), gear's
  // Mote-axis analog to attackPower. Modeled through the stat layer same as
  // every sibling getter above, but — like all of them — not yet actually
  // applied in combat: CombatService.applyDamage is still a flat
  // placeholder (see its own TODO) that doesn't consult playerCombatStats
  // at all yet, for any stat, Mote Potency included.
  get motePotency => statModifierStats.additionalMotePotencyPercentage;
}
