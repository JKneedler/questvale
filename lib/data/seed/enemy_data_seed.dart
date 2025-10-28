import 'package:questvale/data/models/enemy_attack_data.dart';
import 'package:questvale/data/models/enemy_data.dart';
import 'package:questvale/data/models/enemy_drop_data.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:sqflite/sqflite.dart';

List<EnemyData> enemyData = [
  EnemyData(
    id: 'field-rat',
    questZoneId: 'fieldlands',
    name: 'Field Rat',
    rarity: Rarity.common,
    enemyType: EnemyType.beast,
    experience: 8,
    health: 10,
    minGold: 0,
    maxGold: 3,
    spawnRate: 0.3,
    immunities: [],
    resistances: [],
    weaknesses: [DamageType.fire],
    attacks: [
      EnemyAttackData(
        id: 'field-rat-bite',
        name: 'Bite',
        damage: 3,
        damageType: DamageType.physical,
        cooldown: 5,
        weight: 1,
      ),
    ],
    drops: [
      EnemyDropData(
        id: 'field-rat-rat-tail',
        itemName: 'Rat Tail',
        itemQuantityMin: 1,
        itemQuantityMax: 2,
        useCases: [DropItemUseCase.alchemy, DropItemUseCase.crafting],
        rarity: Rarity.common,
        dropChance: 0.65,
      ),
    ],
  ),
  EnemyData(
    id: 'bog-slime',
    questZoneId: 'fieldlands',
    name: 'Bog Slime',
    rarity: Rarity.common,
    enemyType: EnemyType.monster,
    experience: 10,
    health: 12,
    minGold: 0,
    maxGold: 5,
    spawnRate: 0.25,
    immunities: [],
    resistances: [],
    weaknesses: [],
    attacks: [
      EnemyAttackData(
        id: 'bog-slime-slam',
        name: 'Slam',
        damage: 4,
        damageType: DamageType.physical,
        cooldown: 6,
        weight: 1,
      ),
    ],
    drops: [
      EnemyDropData(
        id: 'bog-slime-slime-goo',
        itemName: 'Slime Goo',
        itemQuantityMin: 1,
        itemQuantityMax: 3,
        useCases: [DropItemUseCase.alchemy, DropItemUseCase.material],
        rarity: Rarity.common,
        dropChance: 0.75,
      ),
    ],
  ),
  EnemyData(
    id: 'wild-wolf',
    questZoneId: 'fieldlands',
    name: 'Wild Wolf',
    rarity: Rarity.common,
    enemyType: EnemyType.beast,
    experience: 15,
    health: 18,
    minGold: 2,
    maxGold: 6,
    spawnRate: 0.2,
    immunities: [],
    resistances: [],
    weaknesses: [DamageType.fire],
    attacks: [
      EnemyAttackData(
        id: 'wild-wolf-claw-swipe',
        name: 'Claw Swipe',
        damage: 5,
        damageType: DamageType.physical,
        cooldown: 7,
        weight: 1,
      ),
    ],
    drops: [
      EnemyDropData(
        id: 'wild-wolf-wolf-pelt',
        itemName: 'Wolf Pelt',
        itemQuantityMin: 1,
        itemQuantityMax: 1,
        useCases: [DropItemUseCase.crafting],
        rarity: Rarity.common,
        dropChance: 0.55,
      ),
    ],
  ),
  EnemyData(
    id: 'field-hawk',
    questZoneId: 'fieldlands',
    name: 'Field Hawk',
    rarity: Rarity.common,
    enemyType: EnemyType.beast,
    experience: 12,
    health: 14,
    minGold: 1,
    maxGold: 4,
    spawnRate: 0.1,
    immunities: [],
    resistances: [],
    weaknesses: [],
    attacks: [
      EnemyAttackData(
        id: 'field-hawk-dive-peck',
        name: 'Dive Peck',
        damage: 6,
        damageType: DamageType.physical,
        cooldown: 5,
        weight: 1,
      ),
    ],
    drops: [
      EnemyDropData(
        id: 'field-hawk-feather',
        itemName: 'Feather',
        itemQuantityMin: 1,
        itemQuantityMax: 2,
        useCases: [DropItemUseCase.crafting],
        rarity: Rarity.common,
        dropChance: 0.65,
      ),
    ],
  ),
  EnemyData(
    id: 'grass-viper',
    questZoneId: 'fieldlands',
    name: 'Grass Viper',
    rarity: Rarity.uncommon,
    enemyType: EnemyType.beast,
    experience: 18,
    health: 20,
    minGold: 4,
    maxGold: 8,
    spawnRate: 0.15,
    immunities: [],
    resistances: [DamageType.poison],
    weaknesses: [DamageType.ice],
    attacks: [
      EnemyAttackData(
        id: 'grass-viper-bite',
        name: 'Bite',
        damage: 6,
        damageType: DamageType.physical,
        cooldown: 6,
        weight: .8,
      ),
      EnemyAttackData(
        id: 'grass-viper-venom-spit',
        name: 'Venom Spit',
        damage: 4,
        damageType: DamageType.poison,
        cooldown: 6,
        weight: .2,
      ),
    ],
    drops: [
      EnemyDropData(
        id: 'grass-viper-venom-gland',
        itemName: 'Venom Gland',
        itemQuantityMin: 1,
        itemQuantityMax: 1,
        useCases: [DropItemUseCase.alchemy],
        rarity: Rarity.uncommon,
        dropChance: 0.4,
      ),
      EnemyDropData(
        id: 'grass-viper-venom-gland-1',
        itemName: 'Venom Gland',
        itemQuantityMin: 1,
        itemQuantityMax: 1,
        useCases: [DropItemUseCase.alchemy],
        rarity: Rarity.rare,
        dropChance: 0.4,
      ),
    ],
  ),
];

Future<void> seedEnemyData(Database db) async {
  for (final enemy in enemyData) {
    await db.insert(EnemyData.enemyDataTableName, enemy.toMap());

    for (final attack in enemy.attacks) {
      await db.insert(
          EnemyAttackData.enemyAttackDataTableName, attack.toMap(enemy.id));
    }

    for (final drop in enemy.drops) {
      await db.insert(
          EnemyDropData.enemyDropDataTableName, drop.toMap(enemy.id));
    }
  }
}
