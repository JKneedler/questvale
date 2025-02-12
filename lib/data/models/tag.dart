class Tag {
  static const tagTableName = 'Tags';

  static const idColumnName = 'id';
  static const nameColumnName = 'name';

  static const createTableSQL = '''
		CREATE TABLE ${Tag.tagTableName}(
			${Tag.idColumnName} VARCHAR PRIMARY KEY, 
			${Tag.nameColumnName} VARCHAR NOT NULL
		);
	''';

  final String id;
  final String name;

  const Tag({
    required this.id,
    required this.name,
  });

  Map<String, Object?> toMap() {
    return {
      Tag.idColumnName: id,
      Tag.nameColumnName: name,
    };
  }

  @override
  String toString() {
    return 'Tag {id: $id, name: $name}';
  }

  Tag copyWith({
    String? name,
  }) {
    return Tag(id: id, name: name ?? this.name);
  }
}
