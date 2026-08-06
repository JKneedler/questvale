import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/providers/game_data_models/enemy_attack_data.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:sqflite/sqflite.dart';

class DamageData {
  final double damageMultiplier;
  final SkillDamageType damageType;

  DamageData({required this.damageMultiplier, required this.damageType});
}

class DamageResult {
  final int damageDone;
  final bool didKill;

  DamageResult({required this.damageDone, required this.didKill});
}

class CombatService {
  final Database db;
  late CharacterRepository characterRepository;
  late EnemyRepository enemyRepository;

  CombatService({required this.db}) {
    characterRepository = CharacterRepository(db: db);
    enemyRepository = EnemyRepository(db: db);
  }

  Future<DamageResult> applyDamage(
      DamageData damageData, String enemyId) async {
    final enemy = await enemyRepository.getEnemyById(enemyId);
    // TODO : Recalculate the player combat stats and apply that to the damage calculation
    // final damage = damageData.damageMultiplier * playerCombatStats.physicalAttackPower;
    final int damage = (damageData.damageMultiplier * 10).toInt();
    int damageDone = 0;
    bool didKill = false;
    if (enemy.currentHealth < damage) {
      damageDone = enemy.currentHealth;
      didKill = true;
    } else {
      damageDone = damage;
    }
    final newHealth = enemy.currentHealth - damageDone;
    if (newHealth <= 0) didKill = true;
    await enemyRepository.updateEnemy(enemy.copyWith(currentHealth: newHealth));
    return DamageResult(damageDone: damageDone, didKill: didKill);
  }

  // Enemy -> player direction, fired when a ScheduledTimer resolves (see
  // EnemyAttackSchedulingService). Flat damage straight off the static
  // attack data, matching applyDamage's existing lack of stat recalculation
  // above rather than inventing a separate defense formula here.
  Future<EnemyAttackDamageResult> applyEnemyAttackDamage(
      EnemyAttackData attack, Character character) async {
    final newHealth = (character.currentHealth - attack.damage)
        .clamp(0, character.maxHealth)
        .toInt();
    // The amount actually taken, not the raw attack stat — clamped at 0 HP
    // means a killing blow can deal less than its listed damage.
    final damageDealt = character.currentHealth - newHealth;
    final updated = character.copyWith(currentHealth: newHealth);
    final persisted = await characterRepository.updateCharacter(updated);
    return EnemyAttackDamageResult(
        character: persisted, damageDealt: damageDealt);
  }
}

class EnemyAttackDamageResult {
  final Character character;
  final int damageDealt;

  EnemyAttackDamageResult(
      {required this.character, required this.damageDealt});
}
