class TodoTag {
  static const todoTagTableName = 'TodoTags';

  static const idColumnName = 'id';
  static const todoIdColumnName = 'todoId';
  static const characterTagIdColumnName = 'characterTagId';

  static const createTableSQL = '''
		CREATE TABLE ${TodoTag.todoTagTableName}(
			${TodoTag.idColumnName} VARCHAR PRIMARY KEY, 
			${TodoTag.todoIdColumnName} VARCHAR NOT NULL, 
			${TodoTag.characterTagIdColumnName} VARCHAR NOT NULL
		);
	''';

  final String id;
  final String todoId;
  final String characterTagId;

  const TodoTag({
    required this.id,
    required this.todoId,
    required this.characterTagId,
  });

  Map<String, Object?> toMap() {
    return {
      TodoTag.idColumnName: id,
      TodoTag.todoIdColumnName: todoId,
      TodoTag.characterTagIdColumnName: characterTagId,
    };
  }

  @override
  String toString() {
    return 'TodoTag(id: $id, todoId: $todoId, characterTagId: $characterTagId)';
  }

  TodoTag copyWith({
    String? todoId,
    String? characterTagId,
  }) {
    return TodoTag(
      id: id,
      todoId: todoId ?? this.todoId,
      characterTagId: characterTagId ?? this.characterTagId,
    );
  }
}
