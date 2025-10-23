enum CharacterClass {
  warrior,
  rogue,
  mage,
}

enum CombatStat {
  baseMaxHealth,
  maxHealthMult,
  baseMaxMana,
  maxManaMult,
  luck,
  enemyExpMult,
  questExpMult,
  enemyGoldMult,
  questGoldMult,
  taskEfficiency,
  baseDamage,
  damageMult,
  baseCritChance,
  critChanceMult,
  baseCritDamageMult,
  critDamageMult,
  skillCooldownMult,
  lifesteal,
  humanoidDamageMult,
  undeadDamageMult,
  beastDamageMult,
  bossDamageMult,
  baseBlockChance,
  blockChanceMult,
  healthRegen,
  baseArmor,
  armorMult,
  burnChance,
  freezeChance,
  shockChance,
  poisonChance,
  stunChance,
  fireDamageMult,
  iceDamageMult,
  lightningDamageMult,
  poisonDamageMult,
  damageReduction,
  fireResistance,
  iceResistance,
  lightningResistance,
  poisonResistance,
  healingMult,
  buffDurationMult,
  ailmentDurationMult,
  fakeNullCatch,
}

class Character {
  static const characterTableName = 'Characters';

  static const idColumnName = 'id';
  static const nameColumnName = 'name';
  static const characterClassColumnName = 'characterClass';
  static const levelColumnName = 'level';
  static const currentExpColumnName = 'currentExp';
  static const currentHealthColumnName = 'currentHealth';
  static const currentManaColumnName = 'currentMana';
  static const attacksRemainingColumnName = 'attacksRemainingColumnName';

  static const createTableSQL = '''
		CREATE TABLE ${Character.characterTableName}(
			${Character.idColumnName} VARCHAR PRIMARY KEY,
			${Character.nameColumnName} VARCHAR NOT NULL,
			${Character.characterClassColumnName} INTEGER NOT NULL,
			${Character.levelColumnName} INTEGER NOT NULL,
			${Character.currentExpColumnName} INTEGER NOT NULL,
			${Character.currentHealthColumnName} INTEGER NOT NULL,
			${Character.currentManaColumnName} INTEGER NOT NULL,
			${Character.attacksRemainingColumnName} INTEGER NOT NULL
		);
	''';

  final String id;
  final String name;
  final CharacterClass characterClass;
  final int level;
  final int currentExp;
  final int currentHealth;
  final int currentMana;
  final int attacksRemaining;

  late Map<CombatStat, double> combatStats;

  Character({
    required this.id,
    required this.name,
    required this.characterClass,
    required this.level,
    required this.currentExp,
    required this.currentHealth,
    required this.currentMana,
    required this.attacksRemaining,
  }) {
    calculateCombatStats();
  }

  int get maxHealth {
    return (combatStats[CombatStat.baseMaxHealth]! *
            combatStats[CombatStat.maxHealthMult]!)
        .toInt();
  }

  int get maxMana {
    return (combatStats[CombatStat.baseMaxMana]! *
            combatStats[CombatStat.maxManaMult]!)
        .toInt();
  }

  int get attackDamage {
    return (combatStats[CombatStat.baseDamage]! *
            combatStats[CombatStat.damageMult]!)
        .toInt();
  }

  Map<String, Object?> toMap() {
    return {
      Character.idColumnName: id,
      Character.nameColumnName: name,
      Character.characterClassColumnName: characterClass.index,
      Character.levelColumnName: level,
      Character.currentExpColumnName: currentExp,
      Character.currentHealthColumnName: currentHealth,
      Character.currentManaColumnName: currentMana,
      Character.attacksRemainingColumnName: attacksRemaining,
    };
  }

  @override
  String toString() {
    return 'Character {id: $id, name: $name, characterClass: $characterClass, level: $level, currentExp: $currentExp, currentHealth: $currentHealth, currentMana: $currentMana, attacksRemaining: $attacksRemaining}';
  }

  Character copyWith({
    String? name,
    CharacterClass? characterClass,
    int? level,
    int? currentExp,
    int? currentHealth,
    int? currentMana,
    int? attacksRemaining,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      characterClass: characterClass ?? this.characterClass,
      level: level ?? this.level,
      currentExp: currentExp ?? this.currentExp,
      currentHealth: currentHealth ?? this.currentHealth,
      currentMana: currentMana ?? this.currentMana,
      attacksRemaining: attacksRemaining ?? this.attacksRemaining,
    );
  }

  void calculateCombatStats() {
    Map<CombatStat, double> baseStats = {
      CombatStat.baseMaxHealth: 20, // level & class
      CombatStat.maxHealthMult: 1,
      CombatStat.baseMaxMana: 10, // level & class
      CombatStat.maxManaMult: 1,
      CombatStat.luck: 1,
      CombatStat.enemyExpMult: 1,
      CombatStat.questExpMult: 1,
      CombatStat.enemyGoldMult: 1,
      CombatStat.questGoldMult: 1,
      CombatStat.taskEfficiency: 1,
      //CombatStat.baseDamage: inventory.baseDamage.toDouble(),
      CombatStat.damageMult: 1,
      //CombatStat.baseCritChance: inventory.baseCritChance, // class & gear
      CombatStat.critChanceMult: 1,
      //CombatStat.baseCritDamageMult: inventory.baseCritDamageMult, // class & gear
      CombatStat.critDamageMult: 1,
      CombatStat.skillCooldownMult: 1,
      CombatStat.lifesteal: 0,
      CombatStat.humanoidDamageMult: 1,
      CombatStat.undeadDamageMult: 1,
      CombatStat.beastDamageMult: 1,
      CombatStat.bossDamageMult: 1,
      //CombatStat.baseBlockChance: inventory.baseBlockChance.toDouble(),
      CombatStat.blockChanceMult: 1,
      CombatStat.healthRegen: 0,
      //CombatStat.baseArmor: inventory.baseArmor.toDouble(),
      CombatStat.armorMult: 1,
      CombatStat.burnChance: 0,
      CombatStat.freezeChance: 0,
      CombatStat.shockChance: 0,
      CombatStat.poisonChance: 0,
      CombatStat.stunChance: 0,
      CombatStat.fireDamageMult: 1,
      CombatStat.iceDamageMult: 1,
      CombatStat.lightningDamageMult: 1,
      CombatStat.poisonDamageMult: 1,
      CombatStat.damageReduction: 0,
      CombatStat.fireResistance: 0,
      CombatStat.iceResistance: 0,
      CombatStat.lightningResistance: 0,
      CombatStat.poisonResistance: 0,
      CombatStat.healingMult: 1,
      CombatStat.buffDurationMult: 1,
      CombatStat.ailmentDurationMult: 1,
      CombatStat.fakeNullCatch: 0,
    };

    //final equipmentModifiers = inventory.statModifiers;
    // for (Pair<CombatStat, double> modifier in equipmentModifiers) {
    //   baseStats[modifier.key] = baseStats[modifier.key]! + modifier.value;
    // }
    combatStats = baseStats;
  }
}
