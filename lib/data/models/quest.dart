import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/quest_room.dart';

class Quest {
  static const String questTableName = 'Quests';

  static const String idColumnName = 'id';
  static const String characterColumnName = 'character';
  static const String nameColumnName = 'name';
  static const String isActiveColumnName = 'isActive';

  static const createTableSQL = '''
		CREATE TABLE ${Quest.questTableName}(
			${Quest.idColumnName} VARCHAR PRIMARY KEY,
			${Quest.characterColumnName} VARCHAR NOT NULL,
			${Quest.nameColumnName} VARCHAR NOT NULL,
			${Quest.isActiveColumnName} BOOLEAN NOT NULL
		);
	''';

  final String id;
  final String characterId;
  final Character? character;
  final String name;
  final bool isActive;
  final List<QuestRoom> rooms;

  const Quest({
    required this.id,
    required this.characterId,
    this.character,
    required this.name,
    required this.isActive,
    required this.rooms,
  });

  QuestRoom get currentRoom => rooms.firstWhere((room) => !room.isCompleted);

  int get currentRoomNumber => rooms.indexOf(currentRoom) + 1;

  bool get allRoomsCompleted => !rooms.any((room) => !room.isCompleted);

  Map<String, Object?> toMap() {
    return {
      Quest.idColumnName: id,
      Quest.characterColumnName: characterId,
      Quest.nameColumnName: name,
      Quest.isActiveColumnName: isActive ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'Quest { id: $id, character: $characterId, name: $name, isActive: $isActive, # of rooms: ${rooms.length}, currentRoomNumber: $currentRoomNumber }';
  }

  Quest copyWith({
    String? characterId,
    Character? character,
    String? name,
    bool? isActive,
    int? currentRoomNumber,
    List<QuestRoom>? rooms,
  }) {
    return Quest(
      id: id,
      characterId: characterId ?? this.characterId,
      character: character ?? this.character,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      rooms: rooms ?? this.rooms,
    );
  }
}
