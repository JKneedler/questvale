import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/services/combat_service.dart';
import 'package:questvale/services/mote_service.dart';

abstract class BaseActiveSkill {
  final String id;
  final SkillData data;
  final int level;

  BaseActiveSkill({
    required this.id,
    required this.data,
    required this.level,
  });

  String get description;

  // Shared 'x%' description-template formatter — primaryBaseValue etc. are
  // stored as fractions (1.5 == 150%), so every skill needs the same *100
  // conversion when substituting into its description string.
  String percentText(double? value) => '${((value ?? 0) * 100).round()}%';

  // moteResult is the already-resolved outcome of this cast against the
  // caster's Mote bank — CombatCubit resolves it via MoteService before
  // calling execute (generation/fizzle has to happen for every cast
  // regardless of whether the skill itself cares, and a consumer skill
  // needs motesConsumed up front to scale its own effect). Skills that
  // don't interact with motes (data.moteInteraction == none) can just
  // ignore the parameter — it resolves to MoteInteractionResult.none for
  // them automatically.
  Future<void> execute(
      CombatService combatService,
      PlayerCombatStats playerCombatStats,
      List<Enemy> targettedEnemies,
      MoteInteractionResult moteResult) async {
    return;
  }

  // damageMultiplierOverride lets a mote-consumer skill (Ember Burst,
  // Hoarfrost Burst) pass a multiplier computed from motesConsumed instead
  // of the flat data.primaryBaseValue every other skill uses as-is.
  Future<List<DamageResult>> basicEnemyDamage(
      CombatService combatService,
      PlayerCombatStats playerCombatStats,
      List<Enemy> enemies, {
    double? damageMultiplierOverride,
  }) async {
    List<DamageResult> damageResults = [];
    for (int i = 0; i < enemies.length; i++) {
      if (data.targetingType == SkillTargetingType.singleEnemy && i != 0) break;

      final damageData = DamageData(
          damageMultiplier:
              damageMultiplierOverride ?? data.primaryBaseValue ?? 1,
          damageType: data.damageType ?? SkillDamageType.physical);
      final damageResult =
          await combatService.applyDamage(damageData, enemies[i].id);
      print(
          '${data.name} dealt ${damageResult.damageDone} damage to ${enemies[i].id} and ${damageResult.didKill ? 'killed' : 'did not kill'} it');
      damageResults.add(damageResult);
    }
    return damageResults;
  }
}
