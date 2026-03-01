import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_state.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:questvale/services/combat_service.dart';
import 'package:sqflite/sqflite.dart';

class CombatCubit extends Cubit<CombatState> {
  final String encounterId;
  late EnemyRepository enemyRepository;
  late CombatService combatService;

  CombatCubit({required this.encounterId, required Database db})
      : super(CombatState(enemies: [])) {
    enemyRepository = EnemyRepository(db: db);
    combatService = CombatService(db: db);
    init();
  }

  Future<void> init() async {
    reload();
  }

  Future<void> reload() async {
    final enemies = await enemyRepository.getEnemiesByEncounterId(encounterId);
    CombatStatus newStatus = state.status;
    if (state.status != CombatStatus.complete) {
      if (enemies.every((enemy) => enemy.currentHealth <= 0)) {
        newStatus = CombatStatus.complete;
      }
    }
    if (!isClosed) {
      emit(state.copyWith(enemies: enemies, status: newStatus));
    }
  }

  void setIdle() {
    emit(
      state.copyWith(
        status: CombatStatus.idle,
        inspectingEnemyIndex: -1,
        targetingSkillIndex: -1,
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

  void onSkillButtonTap(BuildContext context, int skillIndex) {
    final CombatState previousState = state;
    CombatStatus newStatus = previousState.status;
    SkillTarget newTarget = previousState.target;
    int newTargetingSkillIndex = previousState.targetingSkillIndex;

    if (previousState.status == CombatStatus.targetingSkill) {
      if (previousState.targetingSkillIndex == skillIndex) {
        newStatus = CombatStatus.idle;
        newTargetingSkillIndex = -1;
      } else {
        newTargetingSkillIndex = skillIndex;
        newTarget = getNewTarget(skillIndex);
      }
    } else {
      newStatus = CombatStatus.targetingSkill;
      newTargetingSkillIndex = skillIndex;
      newTarget = getNewTarget(skillIndex);
    }
    emit(previousState.copyWith(
        status: newStatus,
        target: newTarget,
        targetingSkillIndex: newTargetingSkillIndex));
  }

  SkillTarget getNewTarget(int skillIndex) {
    // TODO: Set new target appropriately based on skill targeting and what enemies are alive, etc.
    return SkillTarget.enemy1;
  }
}
