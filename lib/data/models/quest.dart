import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/quest_room.dart';

class Quest {
  static const String questTableName = 'Quests';

  static const String idColumnName = 'id';
  static const String characterColumnName = 'character';
  static const String nameColumnName = 'name';
  static const String isActiveColumnName = 'isActive';
  static const String currentRoomNumberColumnName = 'currentRoomNumber';

  static const createTableSQL = '''
		CREATE TABLE ${Quest.questTableName}(
			${Quest.idColumnName} VARCHAR PRIMARY KEY,
			${Quest.characterColumnName} VARCHAR NOT NULL,
			${Quest.nameColumnName} VARCHAR NOT NULL,
			${Quest.isActiveColumnName} BOOLEAN NOT NULL,
			${Quest.currentRoomNumberColumnName} INTEGER NOT NULL
		);
	''';

  final String id;
  final String characterId;
  final Character? character;
  final String name;
  final bool isActive;
  final int currentRoomNumber;
  final List<QuestRoom> rooms;

  const Quest({
    required this.id,
    required this.characterId,
    this.character,
    required this.name,
    required this.isActive,
    required this.currentRoomNumber,
    required this.rooms,
  });

  Map<String, Object?> toMap() {
    return {
      Quest.idColumnName: id,
      Quest.characterColumnName: characterId,
      Quest.nameColumnName: name,
      Quest.isActiveColumnName: isActive ? 1 : 0,
      Quest.currentRoomNumberColumnName: currentRoomNumber,
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
      currentRoomNumber: currentRoomNumber ?? this.currentRoomNumber,
      rooms: rooms ?? this.rooms,
    );
  }
}
