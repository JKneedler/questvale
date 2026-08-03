class CharacterTag {
  static const characterTagTableName = 'CharacterTags';

  static const idColumnName = 'id';
  static const characterIdColumnName = 'characterId';
  static const nameColumnName = 'name';

  static const createTableSQL = '''
		CREATE TABLE ${CharacterTag.characterTagTableName}(
			${CharacterTag.idColumnName} VARCHAR PRIMARY KEY,
			${CharacterTag.characterIdColumnName} VARCHAR NOT NULL,
			${CharacterTag.nameColumnName} VARCHAR NOT NULL
		);
	''';

  final String id;
  final String characterId;
  final String name;

  const CharacterTag({
    required this.id,
    required this.characterId,
    required this.name,
  });

  Map<String, Object?> toMap() {
    return {
      CharacterTag.idColumnName: id,
      CharacterTag.characterIdColumnName: characterId,
      CharacterTag.nameColumnName: name,
    };
  }

  @override
  String toString() {
    return 'CharacterTag(id: $id, characterId: $characterId, name: $name)';
  }

  CharacterTag copyWith({
    String? name,
  }) {
    return CharacterTag(
      id: id,
      characterId: characterId,
      name: name ?? this.name,
    );
  }
}
