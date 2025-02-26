// Just the class that represents the database object

import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/pair.dart';

enum EquipmentModifierType {
  health,
  mana,
  luck,
  enemyExp,
  questExp,
  enemyGold,
  questGold,
  taskEfficiency,
  skillDamage,
  critChance,
  critDamage,
  skillCooldown,
  lifesteal,
  humanoidDamage,
  undeadDamage,
  beastDamage,
  bossDamage,
  blockChance,
  healthRegen,
  armor,
  burnChance,
  freezeChance,
  shockChance,
  poisonChance,
  stunChance,
  fireDamage,
  iceDamage,
  lightningDamage,
  poisonDamage,
  damageReduction,
  fireRes,
  iceRes,
  lightningRes,
  poisonRes,
  healing,
  buffDuration,
  ailmentDuration,
}

class EquipmentModifier {
  static const String equipmentModifierTableName = 'EquipmentModifiers';

  static const String idColumnName = 'id';
  static const String equipmentColumnName = 'equipment';
  static const String typeColumnName = 'type';
  static const String statColumnName = 'stat';
  static const String valueColumnName = 'value';

  static const String createTableSQL = '''
		CREATE TABLE ${EquipmentModifier.equipmentModifierTableName} (
			${EquipmentModifier.idColumnName} VARCHAR PRIMARY KEY,
			${EquipmentModifier.equipmentColumnName} VARCHAR NOT NULL,
			${EquipmentModifier.typeColumnName} INTEGER NOT NULL,
			${EquipmentModifier.statColumnName} INTEGER NOT NULL,
			${EquipmentModifier.valueColumnName} DOUBLE NOT NULL
		);
	''';

  final String id;
  final String equipmentId;
  final EquipmentModifierType type;
  final CombatStat stat;
  final double value;

  const EquipmentModifier({
    required this.id,
    required this.equipmentId,
    required this.type,
    required this.stat,
    required this.value,
  });

  Map<String, Object?> toMap() {
    return {
      EquipmentModifier.idColumnName: id,
      EquipmentModifier.equipmentColumnName: equipmentId,
      EquipmentModifier.typeColumnName: type.index,
      EquipmentModifier.statColumnName: stat.index,
      EquipmentModifier.valueColumnName: value,
    };
  }

  @override
  String toString() {
    return 'EquipmentModifier { id: $id, equipmentId: $equipmentId, type: ${type.index}, stat: ${stat.index} value: $value }';
  }

  EquipmentModifier copyWith({
    String? equipmentId,
    EquipmentModifierType? type,
    CombatStat? stat,
    double? value,
  }) {
    return EquipmentModifier(
      id: id,
      equipmentId: equipmentId ?? this.equipmentId,
      type: type ?? this.type,
      stat: stat ?? this.stat,
      value: value ?? this.value,
    );
  }

  String get name {
    final modifierInfo = modiferInfoMap[type];
    if (modifierInfo != null) {
      final nameScaffold = modifierInfo['name'] as String;
      final val = value * 100;
      return nameScaffold.replaceFirst(RegExp('_'),
          (val % 1 == 0 ? val.toInt().toString() : val.toString()));
    } else {
      return '<Name not found>';
    }
  }

  Pair<CombatStat, double> get statModification {
    return Pair(stat, value);
  }

  // Character Stats block modifier method
  // CharacterStatModifier applyModifier(CharacterStatModifier statModifier) {}
  static Map<EquipmentModifierType, Map<String, Object>> modiferInfoMap = {
    EquipmentModifierType.health: {
      'name': '+ _% Max Health',
      'stat': CombatStat.maxHealthMult,
      'baseValue': .05,
    },
    EquipmentModifierType.mana: {
      'name': '+ _% Max Mana',
      'stat': CombatStat.maxManaMult,
      'baseValue': .05,
    },
    EquipmentModifierType.luck: {
      'name': '+ _% Luck',
      'stat': CombatStat.luck,
      'baseValue': .1,
    },
    EquipmentModifierType.enemyExp: {
      'name': '+ _% Exp From Enemies',
      'stat': CombatStat.enemyExpMult,
      'baseValue': .1,
    },
    EquipmentModifierType.questExp: {
      'name': '+ _% Exp from Quests',
      'stat': CombatStat.questExpMult,
      'baseValue': .1,
    },
    EquipmentModifierType.enemyGold: {
      'name': '+ _% Gold from Enemies',
      'stat': CombatStat.enemyGoldMult,
      'baseValue': .1,
    },
    EquipmentModifierType.questGold: {
      'name': '+ _% Gold from Quests',
      'stat': CombatStat.questGoldMult,
      'baseValue': .1,
    },
    EquipmentModifierType.taskEfficiency: {
      'name': '+ _% Actions from Tasks',
      'stat': CombatStat.taskEfficiency,
      'baseValue': .05,
    },
    EquipmentModifierType.skillDamage: {
      'name': '+ _% Skill Damage',
      'stat': CombatStat.damageMult,
      'baseValue': .05,
    },
    EquipmentModifierType.critChance: {
      'name': '+ _% Crit Chance',
      'stat': CombatStat.critChanceMult,
      'baseValue': .1,
    },
    EquipmentModifierType.critDamage: {
      'name': '+ _% Crit Damage',
      'stat': CombatStat.critDamageMult,
      'baseValue': .1,
    },
    EquipmentModifierType.skillCooldown: {
      'name': '- _% Skill Cooldown',
      'stat': CombatStat.skillCooldownMult,
      'baseValue': -.1,
    },
    EquipmentModifierType.lifesteal: {
      'name': '+ _% Lifesteal',
      'stat': CombatStat.lifesteal,
      'baseValue': .04,
    },
    EquipmentModifierType.humanoidDamage: {
      'name': '+ _% Damage to Humans',
      'stat': CombatStat.humanoidDamageMult,
      'baseValue': .1,
    },
    EquipmentModifierType.undeadDamage: {
      'name': '+ _% Damage to Undead',
      'stat': CombatStat.undeadDamageMult,
      'baseValue': .1,
    },
    EquipmentModifierType.beastDamage: {
      'name': '+ _% Damage to Beasts',
      'stat': CombatStat.beastDamageMult,
      'baseValue': .1,
    },
    EquipmentModifierType.bossDamage: {
      'name': '+ _% Damage to Bosses',
      'stat': CombatStat.bossDamageMult,
      'baseValue': .1,
    },
    EquipmentModifierType.blockChance: {
      'name': '+ _% Block Chance',
      'stat': CombatStat.blockChanceMult,
      'baseValue': .1,
    },
    EquipmentModifierType.healthRegen: {
      'name': '+ _% Health Regen',
      'stat': CombatStat.healthRegen,
      'baseValue': .02,
    },
    EquipmentModifierType.armor: {
      'name': '+ _% Armor',
      'stat': CombatStat.armorMult,
      'baseValue': .2,
    },
    EquipmentModifierType.burnChance: {
      'name': '+ _% Chance to Burn',
      'stat': CombatStat.burnChance,
      'baseValue': .04,
    },
    EquipmentModifierType.freezeChance: {
      'name': '+ _% Chance to Freeze',
      'stat': CombatStat.freezeChance,
      'baseValue': .04,
    },
    EquipmentModifierType.shockChance: {
      'name': '+ _% Chance to Shock',
      'stat': CombatStat.shockChance,
      'baseValue': .04,
    },
    EquipmentModifierType.poisonChance: {
      'name': '+ _% Chance to Poison',
      'stat': CombatStat.poisonChance,
      'baseValue': .04,
    },
    EquipmentModifierType.stunChance: {
      'name': '+ _% Chance to Stun',
      'stat': CombatStat.stunChance,
      'baseValue': .04,
    },
    EquipmentModifierType.fireDamage: {
      'name': '+ _% Fire Damage',
      'stat': CombatStat.fireDamageMult,
      'baseValue': .1,
    },
    EquipmentModifierType.iceDamage: {
      'name': '+ _% Ice Damage',
      'stat': CombatStat.iceDamageMult,
      'baseValue': .1,
    },
    EquipmentModifierType.lightningDamage: {
      'name': '+ _% Lightning Damage',
      'stat': CombatStat.lightningDamageMult,
      'baseValue': .1,
    },
    EquipmentModifierType.poisonDamage: {
      'name': '+ _% Poison Damage',
      'stat': CombatStat.poisonDamageMult,
      'baseValue': .1,
    },
    EquipmentModifierType.damageReduction: {
      'name': '+ _% Damage Reduction',
      'stat': CombatStat.damageReduction,
      'baseValue': .04,
    },
    EquipmentModifierType.fireRes: {
      'name': '+ _% Fire Resistance',
      'stat': CombatStat.fireResistance,
      'baseValue': .15,
    },
    EquipmentModifierType.iceRes: {
      'name': '+ _% Ice Resistance',
      'stat': CombatStat.iceResistance,
      'baseValue': .15,
    },
    EquipmentModifierType.lightningRes: {
      'name': '+ _% Lightning Resistance',
      'stat': CombatStat.lightningResistance,
      'baseValue': .15,
    },
    EquipmentModifierType.poisonRes: {
      'name': '+ _% Poison Resistance',
      'stat': CombatStat.poisonResistance,
      'baseValue': .15,
    },
    EquipmentModifierType.healing: {
      'name': '+ _% Healing',
      'stat': CombatStat.healingMult,
      'baseValue': .2,
    },
    EquipmentModifierType.buffDuration: {
      'name': '+ _% Buff Duration',
      'stat': CombatStat.buffDurationMult,
      'baseValue': .1,
    },
    EquipmentModifierType.ailmentDuration: {
      'name': '- _% Ailment Duration',
      'stat': CombatStat.ailmentDurationMult,
      'baseValue': -.1,
    },
  };

  static Map<int, List<int>> equipmentTypeModifierMap = {
    EquipmentType.helmet.index: [
      EquipmentModifierType.health.index,
      EquipmentModifierType.mana.index,
      EquipmentModifierType.luck.index,
      EquipmentModifierType.taskEfficiency.index,
      EquipmentModifierType.armor.index,
      EquipmentModifierType.fireRes.index,
      EquipmentModifierType.iceRes.index,
      EquipmentModifierType.lightningRes.index,
      EquipmentModifierType.poisonRes.index,
    ],
    EquipmentType.body.index: [
      EquipmentModifierType.health.index,
      EquipmentModifierType.mana.index,
      EquipmentModifierType.skillCooldown.index,
      EquipmentModifierType.armor.index,
      EquipmentModifierType.damageReduction.index,
      EquipmentModifierType.fireRes.index,
      EquipmentModifierType.iceRes.index,
      EquipmentModifierType.lightningRes.index,
      EquipmentModifierType.poisonRes.index,
      EquipmentModifierType.healing.index,
    ],
    EquipmentType.gloves.index: [
      EquipmentModifierType.health.index,
      EquipmentModifierType.mana.index,
      EquipmentModifierType.enemyExp.index,
      EquipmentModifierType.questExp.index,
      EquipmentModifierType.enemyGold.index,
      EquipmentModifierType.questGold.index,
      EquipmentModifierType.armor.index,
      EquipmentModifierType.fireRes.index,
      EquipmentModifierType.iceRes.index,
      EquipmentModifierType.lightningRes.index,
      EquipmentModifierType.poisonRes.index,
    ],
    EquipmentType.boots.index: [
      EquipmentModifierType.health.index,
      EquipmentModifierType.mana.index,
      EquipmentModifierType.armor.index,
      EquipmentModifierType.fireRes.index,
      EquipmentModifierType.iceRes.index,
      EquipmentModifierType.lightningRes.index,
      EquipmentModifierType.poisonRes.index,
      EquipmentModifierType.buffDuration.index,
      EquipmentModifierType.ailmentDuration.index,
    ],
    EquipmentType.ring.index: [
      EquipmentModifierType.health.index,
      EquipmentModifierType.mana.index,
      EquipmentModifierType.enemyExp.index,
      EquipmentModifierType.enemyGold.index,
      EquipmentModifierType.fireRes.index,
      EquipmentModifierType.iceRes.index,
      EquipmentModifierType.lightningRes.index,
      EquipmentModifierType.poisonRes.index,
      EquipmentModifierType.healing.index,
      EquipmentModifierType.buffDuration.index,
      EquipmentModifierType.ailmentDuration.index,
    ],
    EquipmentType.amulet.index: [
      EquipmentModifierType.health.index,
      EquipmentModifierType.mana.index,
      EquipmentModifierType.questExp.index,
      EquipmentModifierType.enemyGold.index,
      EquipmentModifierType.healthRegen.index,
      EquipmentModifierType.fireRes.index,
      EquipmentModifierType.iceRes.index,
      EquipmentModifierType.lightningRes.index,
      EquipmentModifierType.poisonRes.index,
      EquipmentModifierType.healing.index,
      EquipmentModifierType.buffDuration.index,
      EquipmentModifierType.ailmentDuration.index,
    ],
    EquipmentType.shield.index: [
      EquipmentModifierType.health.index,
      EquipmentModifierType.mana.index,
      EquipmentModifierType.skillCooldown.index,
      EquipmentModifierType.humanoidDamage.index,
      EquipmentModifierType.undeadDamage.index,
      EquipmentModifierType.beastDamage.index,
      EquipmentModifierType.bossDamage.index,
      EquipmentModifierType.blockChance.index,
      EquipmentModifierType.armor.index,
      EquipmentModifierType.stunChance.index,
      EquipmentModifierType.damageReduction.index,
    ],
    EquipmentType.oneHandedWeapon.index: [
      EquipmentModifierType.skillDamage.index,
      EquipmentModifierType.critChance.index,
      EquipmentModifierType.critDamage.index,
      EquipmentModifierType.lifesteal.index,
      EquipmentModifierType.humanoidDamage.index,
      EquipmentModifierType.undeadDamage.index,
      EquipmentModifierType.beastDamage.index,
      EquipmentModifierType.bossDamage.index,
      EquipmentModifierType.burnChance.index,
      EquipmentModifierType.freezeChance.index,
      EquipmentModifierType.shockChance.index,
      EquipmentModifierType.stunChance.index,
    ],
    EquipmentType.twoHandedWeapon.index: [
      EquipmentModifierType.skillDamage.index,
      EquipmentModifierType.critChance.index,
      EquipmentModifierType.critDamage.index,
      EquipmentModifierType.lifesteal.index,
      EquipmentModifierType.humanoidDamage.index,
      EquipmentModifierType.undeadDamage.index,
      EquipmentModifierType.beastDamage.index,
      EquipmentModifierType.bossDamage.index,
      EquipmentModifierType.burnChance.index,
      EquipmentModifierType.freezeChance.index,
      EquipmentModifierType.shockChance.index,
      EquipmentModifierType.stunChance.index,
    ],
    EquipmentType.dagger.index: [
      EquipmentModifierType.skillDamage.index,
      EquipmentModifierType.critChance.index,
      EquipmentModifierType.critDamage.index,
      EquipmentModifierType.lifesteal.index,
      EquipmentModifierType.humanoidDamage.index,
      EquipmentModifierType.undeadDamage.index,
      EquipmentModifierType.beastDamage.index,
      EquipmentModifierType.bossDamage.index,
      EquipmentModifierType.burnChance.index,
      EquipmentModifierType.freezeChance.index,
      EquipmentModifierType.shockChance.index,
      EquipmentModifierType.poisonChance.index,
      EquipmentModifierType.stunChance.index,
    ],
    EquipmentType.bow.index: [
      EquipmentModifierType.skillDamage.index,
      EquipmentModifierType.critChance.index,
      EquipmentModifierType.critDamage.index,
      EquipmentModifierType.humanoidDamage.index,
      EquipmentModifierType.undeadDamage.index,
      EquipmentModifierType.beastDamage.index,
      EquipmentModifierType.bossDamage.index,
      EquipmentModifierType.burnChance.index,
      EquipmentModifierType.freezeChance.index,
      EquipmentModifierType.shockChance.index,
      EquipmentModifierType.poisonChance.index,
      EquipmentModifierType.stunChance.index,
    ],
    EquipmentType.wand.index: [
      EquipmentModifierType.skillDamage.index,
      EquipmentModifierType.critChance.index,
      EquipmentModifierType.critDamage.index,
      EquipmentModifierType.humanoidDamage.index,
      EquipmentModifierType.undeadDamage.index,
      EquipmentModifierType.beastDamage.index,
      EquipmentModifierType.bossDamage.index,
      EquipmentModifierType.burnChance.index,
      EquipmentModifierType.freezeChance.index,
      EquipmentModifierType.shockChance.index,
      EquipmentModifierType.fireDamage.index,
      EquipmentModifierType.iceDamage.index,
      EquipmentModifierType.lightningDamage.index,
    ],
    EquipmentType.staff.index: [
      EquipmentModifierType.skillDamage.index,
      EquipmentModifierType.critChance.index,
      EquipmentModifierType.critDamage.index,
      EquipmentModifierType.humanoidDamage.index,
      EquipmentModifierType.undeadDamage.index,
      EquipmentModifierType.beastDamage.index,
      EquipmentModifierType.bossDamage.index,
      EquipmentModifierType.burnChance.index,
      EquipmentModifierType.freezeChance.index,
      EquipmentModifierType.shockChance.index,
      EquipmentModifierType.fireDamage.index,
      EquipmentModifierType.iceDamage.index,
      EquipmentModifierType.lightningDamage.index,
    ],
    EquipmentType.focus.index: [
      EquipmentModifierType.skillDamage.index,
      EquipmentModifierType.critChance.index,
      EquipmentModifierType.critDamage.index,
      EquipmentModifierType.skillCooldown.index,
      EquipmentModifierType.humanoidDamage.index,
      EquipmentModifierType.undeadDamage.index,
      EquipmentModifierType.beastDamage.index,
      EquipmentModifierType.bossDamage.index,
      EquipmentModifierType.burnChance.index,
      EquipmentModifierType.freezeChance.index,
      EquipmentModifierType.shockChance.index,
      EquipmentModifierType.fireDamage.index,
      EquipmentModifierType.iceDamage.index,
      EquipmentModifierType.lightningDamage.index,
    ],
  };
}
