import 'package:equatable/equatable.dart';

class CharacterSkills extends Equatable {
  static const characterSkillsTableName = 'CharacterSkills';

  static const idColumnName = 'id';
  static const characterIdColumnName = 'characterId';
  static const skillIdColumnName = 'skillId';
  static const levelColumnName = 'level';

  static const createTableSQL = '''
    CREATE TABLE $characterSkillsTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $skillIdColumnName VARCHAR NOT NULL,
      $levelColumnName INTEGER NOT NULL
    );
  ''';

  final String id;
  final String characterId;
  final String skillId;
  final int level;

  const CharacterSkills({
    required this.id,
    required this.characterId,
    required this.skillId,
    required this.level,
  });

  Map<String, Object?> toMap() {
    return {
      idColumnName: id,
      characterIdColumnName: characterId,
      skillIdColumnName: skillId,
      levelColumnName: level,
    };
  }

  @override
  List<Object?> get props => [id, characterId, skillId, level];

  @override
  String toString() {
    return 'CharacterSkills(id: $id, characterId: $characterId, skillId: $skillId, level: $level)';
  }

  CharacterSkills copyWith({
    String? characterId,
    String? skillId,
    int? level,
  }) {
    return CharacterSkills(
      id: id,
      characterId: characterId ?? this.characterId,
      skillId: skillId ?? this.skillId,
      level: level ?? this.level,
    );
  }
}
