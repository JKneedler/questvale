import 'package:questvale/data/models/equipment.dart';

enum StatModifierType {
  attackPower, // flat attack power addition
  physicalDamage, // percentage physical damage multiplier
  fireDamage, // percentage fire damage multiplier
  iceDamage, // percentage ice damage multiplier
  poisonDamage, // percentage poison damage multiplier
  critChance, // percentage crit chance addition
  critDamage, // percentage crit damage addition
  lifeSteal, // percentage life steal addition
  apEfficiency, // percentage action point efficiency addition
  statusEffectChance, // percentage status effect chance addition
  statusEffectDuration, // percentage status effect duration addition
  armor, // flat armor addition
  health, // flat health addition
  cooldown, // percentage cooldown reduction addition
  resourceRegen, // flat resource regen addition
  flaskPotency, // percentage flask heal addition (flask heals go from 50% to 60% with 10% flask potency for example)
  damageReflection, // percentage damage reflection addition
  blockChance, // percentage block chance addition
  expGain, // percentage exp gain addition
  goldGain, // percentage gold gain addition
  fireImmunity, // boolean fire immunity addition
  iceImmunity, // boolean ice immunity addition
  poisonImmunity; // boolean poison immunity addition

  static List<StatModifierType> availableStatModifierTypes(
      EquipmentSlot equipmentSlot) {
    switch (equipmentSlot) {
      case EquipmentSlot.weapon:
        return [
          StatModifierType.attackPower,
          StatModifierType.physicalDamage,
          StatModifierType.fireDamage,
          StatModifierType.iceDamage,
          StatModifierType.poisonDamage,
          StatModifierType.critChance,
          StatModifierType.critDamage,
          StatModifierType.lifeSteal,
          StatModifierType.statusEffectChance,
        ];
      case EquipmentSlot.head:
        return [
          StatModifierType.armor,
          StatModifierType.health,
          StatModifierType.cooldown,
          StatModifierType.resourceRegen,
        ];
      case EquipmentSlot.body:
        return [
          StatModifierType.armor,
          StatModifierType.health,
          StatModifierType.lifeSteal,
          StatModifierType.flaskPotency,
          StatModifierType.damageReflection,
        ];
      case EquipmentSlot.hands:
        return [
          StatModifierType.armor,
          StatModifierType.critChance,
          StatModifierType.critDamage,
          StatModifierType.attackPower,
          StatModifierType.physicalDamage,
          StatModifierType.fireDamage,
          StatModifierType.iceDamage,
          StatModifierType.poisonDamage,
        ];
      case EquipmentSlot.feet:
        return [
          StatModifierType.armor,
          StatModifierType.cooldown,
          StatModifierType.blockChance,
          StatModifierType.statusEffectDuration,
          StatModifierType.expGain,
          StatModifierType.goldGain,
        ];
      case EquipmentSlot.neck:
        return [
          StatModifierType.resourceRegen,
          StatModifierType.cooldown,
          StatModifierType.physicalDamage,
          StatModifierType.fireDamage,
          StatModifierType.iceDamage,
          StatModifierType.poisonDamage,
          StatModifierType.apEfficiency,
          StatModifierType.expGain,
        ];
      case EquipmentSlot.ring:
        return [
          StatModifierType.critChance,
          StatModifierType.critDamage,
          StatModifierType.lifeSteal,
          StatModifierType.apEfficiency,
          StatModifierType.physicalDamage,
          StatModifierType.fireDamage,
          StatModifierType.iceDamage,
          StatModifierType.poisonDamage,
        ];
      default:
        return [];
    }
  }

  double tierValue(int tier) {
    switch (this) {
      case StatModifierType.attackPower:
        return tier * 4;
      case StatModifierType.physicalDamage:
        return tier * .05;
      case StatModifierType.fireDamage:
        return tier * .05;
      case StatModifierType.iceDamage:
        return tier * .05;
      case StatModifierType.poisonDamage:
        return tier * .05;
      case StatModifierType.critChance:
        return tier * .03;
      case StatModifierType.critDamage:
        return tier * .1;
      case StatModifierType.lifeSteal:
        return tier * .04;
      case StatModifierType.statusEffectChance:
        return tier * .05;
      case StatModifierType.statusEffectDuration:
        return tier * .1;
      case StatModifierType.armor:
        return tier * 4;
      case StatModifierType.health:
        return tier * 10;
      case StatModifierType.cooldown:
        return tier * .04;
      case StatModifierType.resourceRegen:
        return tier * 10;
      case StatModifierType.flaskPotency:
        return tier * .05;
      case StatModifierType.damageReflection:
        return tier * .05;
      case StatModifierType.blockChance:
        return tier * .04;
      case StatModifierType.expGain:
        return tier * .1;
      case StatModifierType.goldGain:
        return tier * .1;
      case StatModifierType.fireImmunity:
        return 1.0;
      case StatModifierType.iceImmunity:
        return 1.0;
      case StatModifierType.poisonImmunity:
        return 1.0;
      default:
        return 0.0;
    }
  }

  bool isPercentage() {
    return ![
      StatModifierType.attackPower,
      StatModifierType.armor,
      StatModifierType.health,
      StatModifierType.resourceRegen,
    ].contains(this);
  }

  String get displayName {
    switch (this) {
      case StatModifierType.attackPower:
        return 'Attack Power';
      case StatModifierType.physicalDamage:
        return 'Physical Damage';
      case StatModifierType.fireDamage:
        return 'Fire Damage';
      case StatModifierType.iceDamage:
        return 'Ice Damage';
      case StatModifierType.poisonDamage:
        return 'Poison Damage';
      case StatModifierType.critChance:
        return 'Crit Chance';
      case StatModifierType.critDamage:
        return 'Crit Damage';
      case StatModifierType.lifeSteal:
        return 'Life Steal';
      case StatModifierType.apEfficiency:
        return 'AP Efficiency';
      case StatModifierType.statusEffectChance:
        return 'Status Effect Chance';
      case StatModifierType.statusEffectDuration:
        return 'Status Effect Duration';
      case StatModifierType.armor:
        return 'Armor';
      case StatModifierType.health:
        return 'Health';
      case StatModifierType.cooldown:
        return 'Skill Cooldown';
      case StatModifierType.resourceRegen:
        return 'Resource Regen';
      case StatModifierType.flaskPotency:
        return 'Flask Potency';
      case StatModifierType.damageReflection:
        return 'Damage Reflection';
      case StatModifierType.blockChance:
        return 'Block Chance';
      case StatModifierType.expGain:
        return 'Exp Gain';
      case StatModifierType.goldGain:
        return 'Gold Gain';
      case StatModifierType.fireImmunity:
        return 'Fire Immunity';
      case StatModifierType.iceImmunity:
        return 'Ice Immunity';
      case StatModifierType.poisonImmunity:
        return 'Poison Immunity';
    }
    return '';
  }
}

enum StatModifierLocation {
  character,
  equipment,
  gem,
  potion,
}

class StatModifier {
  static const statModifierTableName = 'StatModifiers';

  static const idColumnName = 'id';
  static const locationColumnName = 'location';
  static const characterIdColumnName = 'characterId';
  static const equipmentIdColumnName = 'equipmentId';
  static const gemIdColumnName = 'gemId';
  static const potionIdColumnName = 'potionId';
  static const typeColumnName = 'type';
  static const tierColumnName = 'tier';

  static const createTableSQL = '''
    CREATE TABLE $statModifierTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $locationColumnName INTEGER NOT NULL,
      $characterIdColumnName VARCHAR,
      $equipmentIdColumnName VARCHAR,
      $gemIdColumnName VARCHAR,
      $potionIdColumnName VARCHAR,
      $typeColumnName INTEGER NOT NULL,
      $tierColumnName INTEGER NOT NULL
    );
  ''';

  final String id;
  final StatModifierLocation location;
  final String? characterId;
  final String? equipmentId;
  final String? gemId;
  final String? potionId;
  final StatModifierType type;
  final int tier;

  const StatModifier({
    required this.id,
    required this.location,
    this.characterId,
    this.equipmentId,
    this.gemId,
    this.potionId,
    required this.type,
    required this.tier,
  });

  Map<String, Object?> toMap() {
    return {
      idColumnName: id,
      locationColumnName: location.index,
      characterIdColumnName: characterId,
      equipmentIdColumnName: equipmentId,
      gemIdColumnName: gemId,
      potionIdColumnName: potionId,
      typeColumnName: type.index,
      tierColumnName: tier,
    };
  }

  String valueString() {
    final value = type.tierValue(tier);
    final numberString = type.isPercentage()
        ? '${(value * 100).toStringAsFixed(0)}%'
        : '${value.toInt()}';
    final isImmunity = type == StatModifierType.fireImmunity ||
        type == StatModifierType.iceImmunity ||
        type == StatModifierType.poisonImmunity;
    final sign = type == StatModifierType.cooldown ? '-' : '+';
    return '${isImmunity ? '' : '$sign$numberString '}${type.displayName}';
  }

  @override
  String toString() {
    return 'StatModifier(id: $id, location: $location, characterId: $characterId, equipmentId: $equipmentId, gemId: $gemId, potionId: $potionId, type: $type, tier: $tier)';
  }

  StatModifier copyWith({
    String? id,
    StatModifierLocation? location,
    String? characterId,
    String? equipmentId,
    String? gemId,
    String? potionId,
    StatModifierType? type,
    int? tier,
  }) {
    return StatModifier(
      id: id ?? this.id,
      location: location ?? this.location,
      characterId: characterId ?? this.characterId,
      equipmentId: equipmentId ?? this.equipmentId,
      gemId: gemId ?? this.gemId,
      potionId: potionId ?? this.potionId,
      type: type ?? this.type,
      tier: tier ?? this.tier,
    );
  }
}
