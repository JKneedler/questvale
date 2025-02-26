import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/quest.dart';

class QuestRoom {
  static const String questRoomTableName = 'QuestRooms';

  static const String idColumnName = 'id';
  static const String questColumnName = 'quest';
  static const String roomNumberColumnName = 'roomNumber';
  static const String isCompletedColumnName = 'isCompleted';

  static const createTableSQL = '''
		CREATE TABLE ${QuestRoom.questRoomTableName}(
			${QuestRoom.idColumnName} VARCHAR PRIMARY KEY,
			${QuestRoom.questColumnName} VARCHAR NOT NULL,
			${QuestRoom.roomNumberColumnName} INTEGER NOT NULL,
			${QuestRoom.isCompletedColumnName} BOOLEAN NOT NULL
		);
	''';

  final String id;
  final String questId;
  final Quest? quest;
  final int roomNumber;
  final bool isCompleted;
  final List<Enemy> enemies;

  const QuestRoom({
    required this.id,
    required this.questId,
    this.quest,
    required this.roomNumber,
    required this.isCompleted,
    required this.enemies,
  });

  bool get allEnemiesDead {
    return !enemies.any((enemy) => !enemy.isDead);
  }

  Map<String, Object?> toMap() {
    return {
      QuestRoom.idColumnName: id,
      QuestRoom.questColumnName: questId,
      QuestRoom.roomNumberColumnName: roomNumber,
      QuestRoom.isCompletedColumnName: isCompleted ? 1 : 0,
    };
  }

  @override
  String toString() {
    final enemyNameList = [for (Enemy enemy in enemies) enemy.name];
    return 'QuestRoom { id: $id, quest: $questId, enemies: [${enemyNameList.join(", ")}], roomNumber: $roomNumber, isCompleted: $isCompleted, allEnemiesDead: $allEnemiesDead}';
  }

  QuestRoom copyWith({
    String? questId,
    Quest? quest,
    int? roomNumber,
    bool? isCompleted,
    List<Enemy>? enemies,
  }) {
    return QuestRoom(
      id: id,
      questId: questId ?? this.questId,
      quest: quest ?? this.quest,
      roomNumber: roomNumber ?? this.roomNumber,
      isCompleted: isCompleted ?? this.isCompleted,
      enemies: enemies ?? this.enemies,
    );
  }
}
