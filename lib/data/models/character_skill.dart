import 'package:questvale/data/models/character.dart';

enum SkillType {
  cleavingStrike,
  shieldBash,
  heavySwing,
  ironConstitution,
  resoluteMight,
  fortifiedStance,
  crushingBlow,
  battleRoar,
  steadfast,
  bloodedWarrior,
  riposte,
  colossalStrike,
  unyieldingGuard,
  juggernaut,
  crushingMomentum,
  unbreakableWall,
  earthsplitter,
  bulwarkOfEternity,
  bloodOfTheAncients,
  warbornTenacity,
}

class BaseSkill {}

class CharacterSkill {
  static const String skillTableName = 'Skills';

  static const String idColumnName = 'id';
  static const String characterColumnName = 'character';
  static const String typeColumnName = 'type';
  static const String levelColumnName = 'level';

  static const String createTableSQL = '''
		CREATE TABLE ${CharacterSkill.skillTableName} (
			${CharacterSkill.idColumnName} VARCHAR PRIMARY KEY,
			${CharacterSkill.characterColumnName} VARCHAR NOT NULL,
			${CharacterSkill.typeColumnName} INTEGER NOT NULL,
			${CharacterSkill.levelColumnName} INTEGER NOT NULL
		);
	''';

  final String id;
  final String characterId;
  final SkillType type;
  final int level;

  const CharacterSkill({
    required this.id,
    required this.characterId,
    required this.type,
    required this.level,
  });

  Map<String, Object?> toMap() {
    return {
      CharacterSkill.idColumnName: id,
      CharacterSkill.characterColumnName: characterId,
      CharacterSkill.typeColumnName: type.index,
      CharacterSkill.levelColumnName: level,
    };
  }

  @override
  String toString() {
    return 'Skill { id: $id, characterId: $characterId, type: ${type.toString()}, level: $level }';
  }

  CharacterSkill copyWith({
    String? characterId,
    SkillType? type,
    int? level,
  }) {
    return CharacterSkill(
      id: id,
      characterId: characterId ?? this.characterId,
      type: type ?? this.type,
      level: level ?? this.level,
    );
  }

  static Map<SkillType, BaseSkill Function()> activeSkillClasses = {
    SkillType.cleavingStrike: () => BaseSkill(),
  };

  static Map<CharacterClass, List<List<SkillType>>> skillTiersView = {
    CharacterClass.warrior: [
      [
        SkillType.cleavingStrike,
        SkillType.shieldBash,
        SkillType.heavySwing,
        SkillType.ironConstitution,
        SkillType.resoluteMight,
      ],
      [
        SkillType.fortifiedStance,
        SkillType.crushingBlow,
        SkillType.battleRoar,
        SkillType.steadfast,
        SkillType.bloodedWarrior,
      ],
      [
        SkillType.riposte,
        SkillType.colossalStrike,
        SkillType.unyieldingGuard,
        SkillType.juggernaut,
        SkillType.crushingMomentum,
      ],
      [
        SkillType.unbreakableWall,
        SkillType.earthsplitter,
        SkillType.bulwarkOfEternity,
        SkillType.bloodOfTheAncients,
        SkillType.warbornTenacity,
      ],
    ]
  };

  static Map<SkillType, Map<String, Object>> skillInfo = {
    SkillType.cleavingStrike: {
      'name': 'Cleaving Strike',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': true,
      'damageMult': 100,
      'apCost': 1,
      'cooldown': 0,
    },
    SkillType.shieldBash: {
      'name': 'Shield Bash',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': true,
      'damageMult': 100,
      'apCost': 1,
      'cooldown': 0,
    },
    SkillType.heavySwing: {
      'name': 'Heavy Swing',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': true,
      'damageMult': 100,
      'apCost': 1,
      'cooldown': 0,
    },
    SkillType.ironConstitution: {
      'name': 'Iron Constitution',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': false,
    },
    SkillType.resoluteMight: {
      'name': 'Resolute Might',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': false,
    },
    SkillType.fortifiedStance: {
      'name': 'Fortified Stance',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': true,
      'damageMult': 100,
      'apCost': 1,
      'cooldown': 0,
    },
    SkillType.crushingBlow: {
      'name': 'Crushing Blow',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': true,
      'damageMult': 100,
      'apCost': 1,
      'cooldown': 0,
    },
    SkillType.battleRoar: {
      'name': 'Battle Roar',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': true,
      'damageMult': 100,
      'apCost': 1,
      'cooldown': 0,
    },
    SkillType.steadfast: {
      'name': 'Steadfast',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': false,
    },
    SkillType.bloodedWarrior: {
      'name': 'Blooded Warrior',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': false,
    },
    SkillType.riposte: {
      'name': 'Riposte',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': true,
      'damageMult': 100,
      'apCost': 1,
      'cooldown': 0,
    },
    SkillType.colossalStrike: {
      'name': 'Colossal Strike',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': true,
      'damageMult': 100,
      'apCost': 1,
      'cooldown': 0,
    },
    SkillType.unyieldingGuard: {
      'name': 'Unyielding Guard',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': true,
      'damageMult': 100,
      'apCost': 1,
      'cooldown': 0,
    },
    SkillType.juggernaut: {
      'name': 'Juggernaut',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': false,
    },
    SkillType.crushingMomentum: {
      'name': 'Crushing Momentum',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': false,
    },
    SkillType.unbreakableWall: {
      'name': 'Unbreakable Wall',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': true,
      'damageMult': 100,
      'apCost': 1,
      'cooldown': 0,
    },
    SkillType.earthsplitter: {
      'name': 'Earthsplitter',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': true,
      'damageMult': 100,
      'apCost': 1,
      'cooldown': 0,
    },
    SkillType.bulwarkOfEternity: {
      'name': 'Bulwark of Eternity',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': true,
      'damageMult': 100,
      'apCost': 1,
      'cooldown': 0,
    },
    SkillType.bloodOfTheAncients: {
      'name': 'Blood of the Ancients',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': false,
    },
    SkillType.warbornTenacity: {
      'name': 'Warborn Tenacity',
      'description': 'This is the cleaving strike',
      'icon': 'images/sword.png',
      'tier': 1,
      'maxLevel': 3,
      'isActive': false,
    },
  };
}
