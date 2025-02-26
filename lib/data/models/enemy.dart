import 'package:questvale/data/models/quest_room.dart';

class Enemy {
  static const String enemyTableName = 'Enemies';

  static const String idColumnName = 'id';
  static const String questRoomColumnName = 'questRoom';
  static const String nameColumnName = 'name';
  static const String currentHealthColumnName = 'currentHealth';
  static const String maxHealthColumnName = 'maxHealth';
  static const String attackDamageColumnName = 'attackDamage';
  static const String attackIntervalColumnName = 'attackInterval';
  static const String lastAttackColumnName = 'lastAttack';

  static const createTableSQL = '''
		CREATE TABLE ${Enemy.enemyTableName} (
			${Enemy.idColumnName} VARCHAR PRIMARY KEY,
			${Enemy.questRoomColumnName} VARCHAR NOT NULL,
			${Enemy.nameColumnName} VARCHAR NOT NULL,
			${Enemy.currentHealthColumnName} INTEGER NOT NULL,
			${Enemy.maxHealthColumnName} INTEGER NOT NULL,
			${Enemy.attackDamageColumnName} INTEGER NOT NULL,
			${Enemy.attackIntervalColumnName} INTEGER NOT NULL,
			${Enemy.lastAttackColumnName} VARCHAR NOT NULL
		);
	''';

  final String id;
  final String questRoomId;
  final QuestRoom? questRoom;
  final String name;
  final int currentHealth;
  final int maxHealth;
  final int attackDamage;
  final int attackInterval;
  final String lastAttack;

  const Enemy({
    required this.id,
    required this.questRoomId,
    this.questRoom,
    required this.name,
    required this.currentHealth,
    required this.maxHealth,
    required this.attackDamage,
    required this.attackInterval,
    required this.lastAttack,
  });

  bool get isDead => (currentHealth <= 0);

  Map<String, Object?> toMap() {
    return {
      Enemy.idColumnName: id,
      Enemy.questRoomColumnName: questRoomId,
      Enemy.nameColumnName: name,
      Enemy.currentHealthColumnName: currentHealth,
      Enemy.maxHealthColumnName: maxHealth,
      Enemy.attackDamageColumnName: attackDamage,
      Enemy.attackIntervalColumnName: attackInterval,
      Enemy.lastAttackColumnName: lastAttack,
    };
  }

  @override
  String toString() {
    return '''Enemy {
				id: $id
				questRoom: $questRoomId
				name: $name
				health: $currentHealth / $maxHealth
				attackDamage: $attackDamage
				attackInterval: $attackInterval
				lastAttack: $lastAttack
			}
		''';
  }

  Enemy copyWith({
    String? questRoomId,
    QuestRoom? questRoom,
    String? name,
    int? currentHealth,
    int? maxHealth,
    int? attackDamage,
    int? attackInterval,
    String? lastAttack,
  }) {
    return Enemy(
      id: id,
      questRoomId: questRoomId ?? this.questRoomId,
      questRoom: questRoom ?? this.questRoom,
      name: name ?? this.name,
      currentHealth: currentHealth ?? this.currentHealth,
      maxHealth: maxHealth ?? this.maxHealth,
      attackDamage: attackDamage ?? this.attackDamage,
      attackInterval: attackInterval ?? this.attackInterval,
      lastAttack: lastAttack ?? this.lastAttack,
    );
  }
}
