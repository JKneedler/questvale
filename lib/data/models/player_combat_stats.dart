import 'package:collection/collection.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/player_stat_modifier_stats.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/shared_enums.dart';

class PlayerCombatStats {
  late PlayerStatModifierStats statModifierStats;
  final int playerLevel;
  final CharacterClass characterClass;
  // The equipped weapon's own DamageType — resolves a skill's `weaponType`
  // damage type (e.g. Arcane Bolt) to whichever element the weapon actually
  // is. Physical if nothing's equipped in the weapon slot, matching a
  // fresh/ungeared character rather than throwing.
  final DamageType weaponDamageType;
  // List<StatusEffect> activeStatusEffects;

  PlayerCombatStats({
    required this.playerLevel,
    required this.characterClass,
    required List<Equipment> equipments,
  }) : weaponDamageType = equipments
                .firstWhereOrNull((e) => e.type.slot == EquipmentSlot.weapon)
                ?.damageType ??
            DamageType.physical {
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

  // The single seam CombatService.applyDamage reads to turn a skill's
  // declared SkillDamageType into an actual number — see the Skill System
  // Foundations ticket (subtask 2). weaponType defers to whichever element
  // the equipped weapon rolls; every other case picks its matching getter
  // above directly.
  double attackPowerFor(SkillDamageType damageType) {
    switch (damageType) {
      case SkillDamageType.weaponType:
        return _attackPowerForDamageType(weaponDamageType);
      case SkillDamageType.physical:
        return physicalAttackPower;
      case SkillDamageType.fire:
        return fireAttackPower;
      case SkillDamageType.ice:
        return iceAttackPower;
      case SkillDamageType.poison:
        return poisonAttackPower;
    }
  }

  double _attackPowerForDamageType(DamageType damageType) {
    switch (damageType) {
      case DamageType.physical:
        return physicalAttackPower;
      case DamageType.fire:
        return fireAttackPower;
      case DamageType.ice:
        return iceAttackPower;
      case DamageType.poison:
        return poisonAttackPower;
    }
  }
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
  // The single source of truth for max HP (see the Skill System Foundations
  // ticket — this replaced the old, separate Character.maxHealth formula,
  // which was class-differentiated but completely gear-blind: gear's Health
  // stat modifier fed additionalHealth here and nowhere else, so it never
  // actually affected the displayed HP bar or how much damage a character
  // could take before dying, both of which read Character.maxHealth
  // instead). characterClass.baseMaxHealth preserves that per-class
  // differentiation (Warrior tankier than Mage); additionalHealth is what
  // makes it gear-aware.
  //
  // Explicitly typed/rounded to int (unlike every sibling getter above,
  // left as implicit/double) — additionalHealth is a double, and maxHealth
  // now feeds int-typed sinks directly (QvBar.maxValue, the
  // applyEnemyAttackDamage clamp), which previously never happened when
  // this getter was only ever multiplied into another double.
  int get maxHealth =>
      (characterClass.baseMaxHealth +
              (BASE_HEALTH_PER_LEVEL * playerLevel) +
              statModifierStats.additionalHealth)
          .round();
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
