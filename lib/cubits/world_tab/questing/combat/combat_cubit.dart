import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_state.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/providers/game_data_models/quest_zone.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:questvale/data/repositories/scheduled_timer_repository.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/services/combat_service.dart';
import 'package:questvale/services/enemy_attack_scheduling_service.dart';
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
    final encounter = await encounterRepository.getEncounterById(encounterId);
    final character = await characterRepository.getSingleCharacter();
    final reconciliation = await enemyAttackSchedulingService.reconcile(
      encounter: encounter,
      character: character,
      enemyDataFor: (enemy) => questZone.enemies
          .firstWhereOrNull((data) => data.id == enemy.enemyDataId),
    );
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
    final playerCombatStats =
        context.read<PlayerCubit>().state.playerCombatStats;
    if (playerCombatStats == null) {
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
      // TODO: Handle attack
      await previousState.targetingSkill!
          .execute(combatService, playerCombatStats, targettedEnemies);
      reload();
    }
  }
}
