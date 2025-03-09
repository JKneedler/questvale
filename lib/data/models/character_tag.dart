import 'package:flutter/material.dart';

class CharacterTag {
  static const characterTagTableName = 'CharacterTags';

  static const idColumnName = 'id';
  static const characterIdColumnName = 'characterId';
  static const nameColumnName = 'name';
  static const colorIndexColumnName = 'colorIndex';
  static const iconIndexColumnName = 'iconIndex';

  static const createTableSQL = '''
		CREATE TABLE ${CharacterTag.characterTagTableName}(
			${CharacterTag.idColumnName} VARCHAR PRIMARY KEY, 
			${CharacterTag.characterIdColumnName} VARCHAR NOT NULL, 
			${CharacterTag.nameColumnName} VARCHAR NOT NULL, 
			${CharacterTag.colorIndexColumnName} INTEGER NOT NULL, 
			${CharacterTag.iconIndexColumnName} INTEGER NOT NULL
		);
	''';

  final String id;
  final String characterId;
  final String name;
  final int colorIndex;
  final int iconIndex;

  const CharacterTag({
    required this.id,
    required this.characterId,
    required this.name,
    required this.colorIndex,
    required this.iconIndex,
  });

  Map<String, Object?> toMap() {
    return {
      CharacterTag.idColumnName: id,
      CharacterTag.characterIdColumnName: characterId,
      CharacterTag.nameColumnName: name,
      CharacterTag.colorIndexColumnName: colorIndex,
      CharacterTag.iconIndexColumnName: iconIndex,
    };
  }

  @override
  String toString() {
    return 'CharacterTag(id: $id, characterId: $characterId, name: $name, colorIndex: $colorIndex, iconIndex: $iconIndex)';
  }

  CharacterTag copyWith({
    String? name,
    int? colorIndex,
    int? iconIndex,
  }) {
    return CharacterTag(
      id: id,
      characterId: characterId,
      name: name ?? this.name,
      colorIndex: colorIndex ?? this.colorIndex,
      iconIndex: iconIndex ?? this.iconIndex,
    );
  }

  static const List<Color> availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
  ];

  static const List<IconData> availableIcons = [
    Icons.work,
    Icons.school,
    Icons.fitness_center,
    Icons.restaurant,
    Icons.shopping_cart,
    Icons.local_hospital,
    Icons.home,
    Icons.directions_car,
    Icons.flight,
    Icons.movie,
    Icons.music_note,
    Icons.sports_esports,
    Icons.book,
    Icons.attach_money,
    Icons.favorite,
    Icons.star,
  ];

  Color get color => availableColors[colorIndex % availableColors.length];
  IconData get icon => availableIcons[iconIndex % availableIcons.length];
}
