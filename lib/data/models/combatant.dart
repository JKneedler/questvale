import 'package:questvale/data/models/quest_room.dart';

class Combatant {
  static const String combatantTableName = 'Combatants';

  static const String idColumnName = 'id';
  static const String questRoomColumnName = 'questRoom';
  static const String nameColumnName = 'name';
  static const String currentHealthColumnName = 'currentHealth';
  static const String maxHealthColumnName = 'maxHealth';
  static const String attackDamageColumnName = 'attackDamage';
  static const String attackIntervalColumnName = 'attackInterval';
  static const String lastAttackColumnName = 'lastAttack';

  static const createTableSQL = '''
		CREATE TABLE ${Combatant.combatantTableName} (
			${Combatant.idColumnName} VARCHAR PRIMARY KEY,
			${Combatant.questRoomColumnName} VARCHAR NOT NULL,
			${Combatant.nameColumnName} VARCHAR NOT NULL,
			${Combatant.currentHealthColumnName} INTEGER NOT NULL,
			${Combatant.maxHealthColumnName} INTEGER NOT NULL,
			${Combatant.attackDamageColumnName} INTEGER NOT NULL,
			${Combatant.attackIntervalColumnName} INTEGER NOT NULL,
			${Combatant.lastAttackColumnName} VARCHAR NOT NULL
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

  const Combatant({
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

  Map<String, Object?> toMap() {
    return {
      Combatant.idColumnName: id,
      Combatant.questRoomColumnName: questRoomId,
      Combatant.nameColumnName: name,
      Combatant.currentHealthColumnName: currentHealth,
      Combatant.maxHealthColumnName: maxHealth,
      Combatant.attackDamageColumnName: attackDamage,
      Combatant.attackIntervalColumnName: attackInterval,
      Combatant.lastAttackColumnName: lastAttack,
    };
  }

  @override
  String toString() {
    return '''Combatant {
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

  Combatant copyWith({
    String? questRoomId,
    QuestRoom? questRoom,
    String? name,
    int? currentHealth,
    int? maxHealth,
    int? attackDamage,
    int? attackInterval,
    String? lastAttack,
  }) {
    return Combatant(
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
