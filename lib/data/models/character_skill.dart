import 'package:equatable/equatable.dart';

class CharacterSkill extends Equatable {
  static const characterSkillTableName = 'CharacterSkill';

  static const idColumnName = 'id';
  static const characterIdColumnName = 'characterId';
  static const skillIdColumnName = 'skillId';
  static const levelColumnName = 'level';

  static const createTableSQL = '''
    CREATE TABLE $characterSkillTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $characterIdColumnName VARCHAR NOT NULL,
      $skillIdColumnName VARCHAR NOT NULL,
      $levelColumnName INTEGER NOT NULL
    );
  ''';

  final String id;
  final String characterId;
  final String skillId;
  final int level;

  const CharacterSkill({
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
    return 'CharacterSkill(id: $id, characterId: $characterId, skillId: $skillId, level: $level)';
  }

  CharacterSkill copyWith({
    String? characterId,
    String? skillId,
    int? level,
  }) {
    return CharacterSkill(
      id: id,
      characterId: characterId ?? this.characterId,
      skillId: skillId ?? this.skillId,
      level: level ?? this.level,
    );
  }
}
