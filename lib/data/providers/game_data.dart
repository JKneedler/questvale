import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:questvale/data/providers/game_data_models/enemy_attack_data.dart';
import 'package:questvale/data/providers/game_data_models/enemy_data.dart';
import 'package:questvale/data/providers/game_data_models/enemy_drop_data.dart';
import 'package:questvale/data/providers/game_data_models/quest_zone.dart';
import 'package:questvale/helpers/shared_enums.dart';

class GameData {
  late final List<QuestZone> questZones;

  GameData._();

  static Future<GameData> load() async {
    final gameData = GameData._();
    gameData.questZones = await gameData.loadQuestZones();
    return gameData;
  }

  Future<List<QuestZone>> loadQuestZones() async {
    final questZonesStr = await rootBundle.loadString('data/quest_zones.json');
    final questZonesJson = jsonDecode(questZonesStr) as List<dynamic>;
    return questZonesJson.map((json) => questZoneFromJson(json)).toList();
  }

  QuestZone questZoneFromJson(Map<String, dynamic> json) {
    return QuestZone(
      id: json['id'] as String,
      name: json['name'] as String,
      requiredLevel: json['requiredLevel'] as int,
      maxLevel: json['maxLevel'] as int,
      minFloors: json['minFloors'] as int,
      maxFloors: json['maxFloors'] as int,
      minEncountersPerFloor: json['minEncountersPerFloor'] as int,
      maxEncountersPerFloor: json['maxEncountersPerFloor'] as int,
      minGold: json['minGold'] as int,
      maxGold: json['maxGold'] as int,
      experience: json['experience'] as int,
      enemies: (json['enemies'] as List<dynamic>)
          .map((enemy) => enemyFromJson(enemy))
          .toList(),
    );
  }

  EnemyData enemyFromJson(Map<String, dynamic> json) {
    return EnemyData(
      id: json['id'] as String,
      name: json['name'] as String,
      rarity: Rarity.values[json['rarity'] as int],
      enemyType: EnemyType.values[json['enemyType'] as int],
      experience: json['experience'] as int,
      health: json['health'] as int,
      minGold: json['minGold'] as int,
      maxGold: json['maxGold'] as int,
      spawnRate: json['spawnRate'] as double,
      immunities: (json['immunities'] as List<dynamic>)
          .map((immunity) => DamageType.values[immunity as int])
          .toList(),
      resistances: (json['resistances'] as List<dynamic>)
          .map((resistance) => DamageType.values[resistance as int])
          .toList(),
      weaknesses: (json['weaknesses'] as List<dynamic>)
          .map((weakness) => DamageType.values[weakness as int])
          .toList(),
      attacks: (json['attacks'] as List<dynamic>)
          .map((attack) => enemyAttackFromJson(attack))
          .toList(),
      drops: (json['drops'] as List<dynamic>)
          .map((drop) => enemyDropFromJson(drop))
          .toList(),
    );
  }

  EnemyAttackData enemyAttackFromJson(Map<String, dynamic> json) {
    return EnemyAttackData(
      name: json['name'] as String,
      damage: json['damage'] as int,
      damageType: DamageType.values[json['damageType'] as int],
      cooldown: json['cooldown'] as double,
      weight: json['weight'] as double,
    );
  }

  EnemyDropData enemyDropFromJson(Map<String, dynamic> json) {
    return EnemyDropData(
      itemName: json['itemName'] as String,
      itemQuantityMin: json['itemQuantityMin'] as int,
      itemQuantityMax: json['itemQuantityMax'] as int,
      useCases: (json['useCases'] as List<dynamic>)
          .map((useCase) => DropItemUseCase.values[useCase as int])
          .toList(),
      rarity: Rarity.values[json['rarity'] as int],
      dropChance: json['dropChance'] as double,
    );
  }
}
