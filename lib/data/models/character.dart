import 'package:equatable/equatable.dart';
import 'package:questvale/helpers/shared_enums.dart';

class Character extends Equatable {
  static const characterTableName = 'Characters';

  static const idColumnName = 'id';
  static const nameColumnName = 'name';
  static const characterClassColumnName = 'characterClass';
  static const levelColumnName = 'level';
  static const goldColumnName = 'gold';
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
			${Character.goldColumnName} INTEGER NOT NULL,
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
  final int gold;
  final int currentExp;
  final int currentHealth;
  final int currentMana;
  final int attacksRemaining;

  const Character({
    required this.id,
    required this.name,
    required this.characterClass,
    required this.level,
    required this.gold,
    required this.currentExp,
    required this.currentHealth,
    required this.currentMana,
    required this.attacksRemaining,
  });

  int get maxHealth {
    return (level * 10) + characterClass.baseMaxHealth;
  }

  int get maxMana {
    return (level * 10) + 10;
  }

  Map<String, Object?> toMap() {
    return {
      Character.idColumnName: id,
      Character.nameColumnName: name,
      Character.characterClassColumnName: characterClass.index,
      Character.levelColumnName: level,
      Character.goldColumnName: gold,
      Character.currentExpColumnName: currentExp,
      Character.currentHealthColumnName: currentHealth,
      Character.currentManaColumnName: currentMana,
      Character.attacksRemainingColumnName: attacksRemaining,
    };
  }

  @override
  String toString() {
    return 'Character {id: $id, name: $name, characterClass: $characterClass, level: $level, gold: $gold, currentExp: $currentExp, currentHealth: $currentHealth, currentMana: $currentMana, attacksRemaining: $attacksRemaining}';
  }

  Character copyWith({
    String? name,
    CharacterClass? characterClass,
    int? level,
    int? gold,
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
      gold: gold ?? this.gold,
      currentExp: currentExp ?? this.currentExp,
      currentHealth: currentHealth ?? this.currentHealth,
      currentMana: currentMana ?? this.currentMana,
      attacksRemaining: attacksRemaining ?? this.attacksRemaining,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        characterClass,
        level,
        gold,
        currentExp,
        currentHealth,
        currentMana,
        attacksRemaining
      ];
}
