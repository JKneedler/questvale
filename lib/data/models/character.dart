class Character {
  static const characterTableName = 'Characters';

  static const idColumnName = 'id';
  static const nameColumnName = 'name';
  static const levelColumnName = 'level';
  static const currentExpColumnName = 'currentExp';
  static const currentHealthColumnName = 'currentHealth';
  static const maxHealthColumnName = 'maxHealth';
  static const currentManaColumnName = 'currentMana';
  static const maxManaColumnName = 'maxMana';
  static const attacksRemainingColumnName = 'attacksRemainingColumnName';

  static const createTableSQL = '''
		CREATE TABLE ${Character.characterTableName}(
			${Character.idColumnName} VARCHAR PRIMARY KEY,
			${Character.nameColumnName} VARCHAR NOT NULL,
			${Character.levelColumnName} INTEGER NOT NULL,
			${Character.currentExpColumnName} INTEGER NOT NULL,
			${Character.currentHealthColumnName} INTEGER NOT NULL,
			${Character.maxHealthColumnName} INTEGER NOT NULL,
			${Character.currentManaColumnName} INTEGER NOT NULL,
			${Character.maxManaColumnName} INTEGER NOT NULL,
			${Character.attacksRemainingColumnName} INTEGER NOT NULL
		);
	''';

  final String id;
  final String name;
  final int level;
  final int currentExp;
  final int currentHealth;
  final int maxHealth;
  final int currentMana;
  final int maxMana;
  final int attacksRemaining;

  const Character({
    required this.id,
    required this.name,
    required this.level,
    required this.currentExp,
    required this.currentHealth,
    required this.maxHealth,
    required this.currentMana,
    required this.maxMana,
    required this.attacksRemaining,
  });

  Map<String, Object?> toMap() {
    return {
      Character.idColumnName: id,
      Character.nameColumnName: name,
      Character.levelColumnName: level,
      Character.currentExpColumnName: currentExp,
      Character.currentHealthColumnName: currentHealth,
      Character.maxHealthColumnName: maxHealth,
      Character.currentManaColumnName: currentMana,
      Character.maxManaColumnName: maxMana,
      Character.attacksRemainingColumnName: attacksRemaining,
    };
  }

  @override
  String toString() {
    return '''
			Character {
				id: $id
				name: $name
				level: $level
				currentExp: $currentExp
				currentHealth: $currentHealth
				maxHealth: $maxHealth
				currentMana: $currentMana
				maxMana: $maxMana
				attacksRemaining: $attacksRemaining
			}
		''';
  }

  Character copyWith({
    String? name,
    int? level,
    int? currentExp,
    int? currentHealth,
    int? maxHealth,
    int? currentMana,
    int? maxMana,
    int? attacksRemaining,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      level: level ?? this.level,
      currentExp: currentExp ?? this.currentExp,
      currentHealth: currentHealth ?? this.currentHealth,
      maxHealth: maxHealth ?? this.maxHealth,
      currentMana: currentMana ?? this.currentMana,
      maxMana: maxMana ?? this.maxMana,
      attacksRemaining: attacksRemaining ?? this.attacksRemaining,
    );
  }
}
