import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_state.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/providers/game_data_models/quest_zone.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:questvale/data/repositories/scheduled_timer_repository.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/services/combat_service.dart';
import 'package:questvale/services/enemy_attack_scheduling_service.dart';
import 'package:questvale/services/status_effect_service.dart';
import 'package:sqflite/sqflite.dart';

class CombatCubit extends Cubit<CombatState> {
  final String encounterId;
  final QuestZone questZone;
  final PlayerCubit playerCubit;
  late EnemyRepository enemyRepository;
  late ScheduledTimerRepository scheduledTimerRepository;
  late EncounterRepository encounterRepository;
  late CharacterRepository characterRepository;
  late CombatService combatService;
  late EnemyAttackSchedulingService enemyAttackSchedulingService;
  late StatusEffectService statusEffectService;

  CombatCubit(
      {required this.encounterId,
      required this.questZone,
      required this.playerCubit,
      required Database db})
      : super(CombatState(enemies: [])) {
    enemyRepository = EnemyRepository(db: db);
    scheduledTimerRepository = ScheduledTimerRepository(db: db);
    encounterRepository = EncounterRepository(db: db);
    characterRepository = CharacterRepository(db: db);
    combatService = CombatService(db: db);
    enemyAttackSchedulingService = EnemyAttackSchedulingService(db: db);
    statusEffectService = StatusEffectService(db: db);
    init();
  }

  Future<void> init() async {
    reload();
  }

  // Reloading also reconciles any overdue enemy attack timers (same engine
  // TodosOverviewCubit uses) rather than just re-reading whatever's in the
  // DB — otherwise an attack timer that expires while this page is open
  // would sit frozen at zero forever, since nothing else in this cubit's
  // tree ever resolves it. playerCubit.loadCharacter() keeps the HP/mana
  // bars at the bottom of this page in sync with any damage reconciliation
  // just applied.
  Future<void> reload() async {
    var encounter = await encounterRepository.getEncounterById(encounterId);
    final character = await characterRepository.getSingleCharacter();
    // Built locally from `character` (just fetched above) rather than read
    // off playerCubit.state — that state reflects the *previous* reload
    // (playerCubit.loadCharacter() runs after this, further down), so
    // building fresh here avoids reconciling against a stale maxHealth.
    final playerCombatStats = PlayerCombatStats(
      playerLevel: character.level,
      characterClass: character.characterClass,
      equipments: character.equippedEquipmentList,
    );
    final reconciliation = await enemyAttackSchedulingService.reconcile(
      encounter: encounter,
      character: character,
      playerCombatStats: playerCombatStats,
      enemyDataFor: (enemy) => questZone.enemies
          .firstWhereOrNull((data) => data.id == enemy.enemyDataId),
    );
    // Own reconcile pass for Burn ticks/Slow expiry — a separate call
    // rather than one unified dispatcher, since only these two non-
    // enemyMove kinds exist so far (see ScheduledTimerKind's doc comment).
    // May just have changed enemy HP (Burn), which the `encounter` fetched
    // above predates — re-fetch after it runs.
    await statusEffectService.reconcile(encounter: encounter);
    encounter = await encounterRepository.getEncounterById(encounterId);
    await playerCubit.loadCharacter();

    final enemies = encounter.enemies;
    CombatStatus newStatus = state.status;
    if (state.status != CombatStatus.complete) {
      if (enemies.every((enemy) => enemy.currentHealth <= 0)) {
        newStatus = CombatStatus.complete;
      } else {
        newStatus = CombatStatus.idle;
      }
    }
    if (!isClosed) {
      emit(state.copyWith(
        enemies: enemies,
        status: newStatus,
        targetingSkill: null,
        target: SkillTarget.none,
        inspectingEnemyIndex: -1,
        attackTimers: reconciliation.attackTimersByEnemyId,
        lastEnemyDamageTaken: reconciliation.totalDamageDealt > 0
            ? reconciliation.totalDamageDealt
            : null,
      ));
    }
  }

  void setIdle() {
    emit(
      state.copyWith(
        status: CombatStatus.idle,
        inspectingEnemyIndex: -1,
        targetingSkill: null,
        target: SkillTarget.none,
      ),
    );
  }

  void onPlayerTap(BuildContext context) {
    CombatStatus previousStatus = state.status;
    CombatStatus newStatus = previousStatus;

    if (previousStatus == CombatStatus.inspectingPlayer) {
      newStatus = CombatStatus.idle;
    } else if (previousStatus == CombatStatus.idle) {
      newStatus = CombatStatus.inspectingPlayer;
    }

    emit(state.copyWith(status: newStatus));
  }

  void onEnemyTap(BuildContext context, int enemyIndex) {
    final CombatState previousState = state;
    CombatStatus newStatus = previousState.status;
    SkillTarget newTarget = previousState.target;
    int newInspectingEnemyIndex = previousState.inspectingEnemyIndex;

    if (previousState.status == CombatStatus.inspectingEnemy) {
      if (previousState.inspectingEnemyIndex == enemyIndex) {
        newStatus = CombatStatus.idle;
        newInspectingEnemyIndex = -1;
      } else {
        newInspectingEnemyIndex = enemyIndex;
      }
    } else if (previousState.status == CombatStatus.targetingSkill) {
      if (previousState.target != SkillTarget.all &&
          previousState.target.getEnemyIndex() != enemyIndex) {
        newTarget = SkillTarget.getEnemyTarget(enemyIndex);
      }
    } else if (previousState.status == CombatStatus.idle) {
      newStatus = CombatStatus.inspectingEnemy;
      newInspectingEnemyIndex = enemyIndex;
    }
    emit(previousState.copyWith(
        status: newStatus,
        target: newTarget,
        inspectingEnemyIndex: newInspectingEnemyIndex));
  }

  void onSkillButtonTap(BuildContext context, BaseActiveSkill tappedSkill) {
    final CombatState previousState = state;
    CombatStatus newStatus = previousState.status;
    SkillTarget newTarget = previousState.target;
    BaseActiveSkill? newTargetingSkill = previousState.targetingSkill;

    if (previousState.status == CombatStatus.targetingSkill) {
      if (previousState.targetingSkill?.id == tappedSkill.id) {
        newStatus = CombatStatus.idle;
        newTargetingSkill = null;
      } else {
        newTargetingSkill = tappedSkill;
        newTarget = getNewTarget(tappedSkill);
      }
    } else {
      newStatus = CombatStatus.targetingSkill;
      newTargetingSkill = tappedSkill;
      newTarget = getNewTarget(tappedSkill);
    }
    emit(previousState.copyWith(
        status: newStatus,
        target: newTarget,
        targetingSkill: newTargetingSkill));
  }

  SkillTarget getNewTarget(BaseActiveSkill tappedSkill) {
    // TODO: Set new target appropriately based on skill targeting and what enemies are alive, etc.
    if (tappedSkill.data.targetingType == SkillTargetingType.allEnemies) {
      return SkillTarget.all;
    } else if (tappedSkill.data.targetingType ==
        SkillTargetingType.singleEnemy) {
      for (int i = 0; i < state.enemies.length; i++) {
        if (state.enemies[i].currentHealth > 0) {
          return SkillTarget.getEnemyTarget(i);
        }
      }
    } else if (tappedSkill.data.targetingType == SkillTargetingType.self) {
      return SkillTarget.self;
    }
    return SkillTarget.none;
  }

  Future<void> onAttackButtonTap(BuildContext context) async {
    final CombatState previousState = state;
    final playerState = context.read<PlayerCubit>().state;
    final playerCombatStats = playerState.playerCombatStats;
    final character = playerState.character;
    if (playerCombatStats == null || character == null) {
      return;
    }
    if (previousState.status == CombatStatus.targetingSkill &&
        previousState.targetingSkill != null) {
      List<Enemy> targettedEnemies = [];
      if (previousState.target == SkillTarget.all) {
        targettedEnemies = previousState.enemies;
      } else if ([SkillTarget.enemy1, SkillTarget.enemy2, SkillTarget.enemy3]
          .contains(previousState.target)) {
        targettedEnemies = [
          previousState.enemies[previousState.target.getEnemyIndex()]
        ];
      }
      // AP check/spend, cooldown check/arm, and class-resource resolution
      // (Mote generation/consumption for Mage) all happen inside castSkill
      // now — see CombatService.castSkill's doc comment. A blocked cast
      // (insufficient AP or still on cooldown) does nothing and isn't
      // reloaded; real UI feedback for why is its own later pass (see the
      // Skill System Foundations ticket) — for now it's just a no-op.
      final result = await combatService.castSkill(
        skill: previousState.targetingSkill!,
        character: character,
        playerCombatStats: playerCombatStats,
        targets: targettedEnemies,
        encounterId: encounterId,
      );
      if (!result.wasCast) {
        print('Skill cast blocked: ${result.blockReason}');
        return;
      }
      reload();
    }
  }
}
