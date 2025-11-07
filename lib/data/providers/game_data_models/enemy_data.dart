import 'package:questvale/data/providers/game_data_models/enemy_attack_data.dart';
import 'package:questvale/data/providers/game_data_models/enemy_drop_data.dart';
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
  final String id;
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

  @override
  String toString() {
    return 'EnemyData(id: $id, name: $name, rarity: $rarity, enemyType: $enemyType, experience: $experience, health: $health, minGold: $minGold, maxGold: $maxGold, spawnRate: $spawnRate, immunities: $immunities, resistances: $resistances, weaknesses: $weaknesses, attacks: $attacks, drops: $drops)';
  }
}
