import 'package:questvale/data/models/enemy_attack_data.dart';
import 'package:questvale/data/models/enemy_drop_data.dart';
import 'package:questvale/helpers/shared_enums.dart';

enum EnemyType {
  humanoid,
  monster,
  undead,
  demon,
  celestial,
  beast,
  spirit,
  elemental,
  mechanical,
  plant,
}

class EnemyData {
  static const enemyDataTableName = 'EnemyData';

  static const idColumnName = 'id';
  static const questZoneIdColumnName = 'questZoneId';
  static const nameColumnName = 'name';
  static const rarityColumnName = 'rarity';
  static const enemyTypeColumnName = 'enemyType';
  static const experienceColumnName = 'experience';
  static const healthColumnName = 'health';
  static const minGoldColumnName = 'minGold';
  static const maxGoldColumnName = 'maxGold';
  static const spawnRateColumnName = 'spawnRate';
  static const immunitiesColumnName = 'immunities';
  static const resistancesColumnName = 'resistances';
  static const weaknessesColumnName = 'weaknesses';

  static const createTableSQL = '''
    CREATE TABLE $enemyDataTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $questZoneIdColumnName VARCHAR NOT NULL,
      $nameColumnName VARCHAR NOT NULL,
      $rarityColumnName INTEGER NOT NULL,
      $enemyTypeColumnName INTEGER NOT NULL,
      $experienceColumnName INTEGER NOT NULL,
      $healthColumnName INTEGER NOT NULL,
      $minGoldColumnName INTEGER NOT NULL,
      $maxGoldColumnName INTEGER NOT NULL,
      $spawnRateColumnName DOUBLE NOT NULL,
      $immunitiesColumnName VARCHAR NOT NULL,
      $resistancesColumnName VARCHAR NOT NULL,
      $weaknessesColumnName VARCHAR NOT NULL
    );
  ''';

  final String id;
  final String questZoneId;
  final String name;
  final Rarity rarity;
  final EnemyType enemyType;
  final int experience;
  final int health;
  final int minGold;
  final int maxGold;
  final double spawnRate;
  final List<DamageType> immunities;
  final List<DamageType> resistances;
  final List<DamageType> weaknesses;
  final List<EnemyAttackData> attacks;
  final List<EnemyDropData> drops;

  const EnemyData({
    required this.id,
    required this.questZoneId,
    required this.name,
    required this.rarity,
    required this.enemyType,
    required this.experience,
    required this.health,
    required this.minGold,
    required this.maxGold,
    required this.spawnRate,
    required this.immunities,
    required this.resistances,
    required this.weaknesses,
    required this.attacks,
    required this.drops,
  });

  Map<String, Object?> toMap() {
    return {
      EnemyData.idColumnName: id,
      EnemyData.questZoneIdColumnName: questZoneId,
      EnemyData.nameColumnName: name,
      EnemyData.rarityColumnName: rarity.index,
      EnemyData.enemyTypeColumnName: enemyType.index,
      EnemyData.experienceColumnName: experience,
      EnemyData.healthColumnName: health,
      EnemyData.minGoldColumnName: minGold,
      EnemyData.maxGoldColumnName: maxGold,
      EnemyData.spawnRateColumnName: spawnRate,
      EnemyData.immunitiesColumnName: immunities.map((e) => e.index).join(','),
      EnemyData.resistancesColumnName:
          resistances.map((e) => e.index).join(','),
      EnemyData.weaknessesColumnName: weaknesses.map((e) => e.index).join(','),
    };
  }

  @override
  String toString() {
    return 'EnemyData(id: $id, questZoneId: $questZoneId, name: $name, rarity: $rarity, enemyType: $enemyType, experience: $experience, health: $health, minGold: $minGold, maxGold: $maxGold, spawnRate: $spawnRate, immunities: $immunities, resistances: $resistances, weaknesses: $weaknesses, attacks: $attacks, drops: $drops)';
  }

  EnemyData copyWith({
    String? questZoneId,
    String? name,
    Rarity? rarity,
    EnemyType? enemyType,
    int? experience,
    int? health,
    int? minGold,
    int? maxGold,
    double? spawnRate,
    List<DamageType>? immunities,
    List<DamageType>? resistances,
    List<DamageType>? weaknesses,
    List<EnemyAttackData>? attacks,
    List<EnemyDropData>? drops,
  }) {
    return EnemyData(
      id: id,
      questZoneId: questZoneId ?? this.questZoneId,
      name: name ?? this.name,
      rarity: rarity ?? this.rarity,
      enemyType: enemyType ?? this.enemyType,
      experience: experience ?? this.experience,
      health: health ?? this.health,
      minGold: minGold ?? this.minGold,
      maxGold: maxGold ?? this.maxGold,
      spawnRate: spawnRate ?? this.spawnRate,
      immunities: immunities ?? this.immunities,
      resistances: resistances ?? this.resistances,
      weaknesses: weaknesses ?? this.weaknesses,
      attacks: attacks ?? this.attacks,
      drops: drops ?? this.drops,
    );
  }
}
