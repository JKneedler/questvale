import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/combat_encounter/combat_encounter_state.dart';
import 'package:questvale/cubits/quest_encounter/quest_encounter_cubit.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:sqflite/sqflite.dart';

class CombatEncounterCubit extends Cubit<CombatEncounterState> {
  final Encounter encounter;
  late QuestRepository questRepository;
  late EncounterRepository encounterRepository;
  late EnemyRepository enemyRepository;

  CombatEncounterCubit({required this.encounter, required Database db})
      : super(CombatEncounterState(enemies: [])) {
    enemyRepository = EnemyRepository(db: db);
    questRepository = QuestRepository(db: db);
    encounterRepository = EncounterRepository(db: db);
    init();
  }

  Future<void> init() async {
    await reloadEnemies();
  }

  Future<void> reloadEnemies() async {
    final enemies = await enemyRepository.getEnemiesByEncounterId(encounter.id);
    if (enemies.every((enemy) => enemy.currentHealth <= 0)) {
      emit(state.copyWith(status: CombatEncounterStatus.complete, enemies: []));
    } else {
      final firstPlay = encounter.createdAt.millisecondsSinceEpoch >
          DateTime.now().millisecondsSinceEpoch - ENCOUNTER_FIRST_PLAY_DELAY;
      emit(state.copyWith(enemies: enemies, firstPlay: firstPlay));
    }
  }

  Future<void> completeEncounter() async {
    emit(state.copyWith(status: CombatEncounterStatus.complete));
  }

  void onSkillButtonTap(BuildContext context, int skillIndex) {
    QuestEncounterCubit questEncounterCubit =
        context.read<QuestEncounterCubit>();
    final newStatus = state.status == CombatEncounterStatus.idle
        ? CombatEncounterStatus.getSkillStatus(skillIndex)
        : CombatEncounterStatus.idle;
    emit(state.copyWith(status: newStatus, target: CombatEncounterTarget.none));
    questEncounterCubit
        .toggleDarkened(newStatus == CombatEncounterStatus.idle ? false : true);
  }

  void onBasicAttackButtonTap(BuildContext context) {
    QuestEncounterCubit questEncounterCubit =
        context.read<QuestEncounterCubit>();
    final newStatus = state.status == CombatEncounterStatus.idle
        ? CombatEncounterStatus.targetSelectBasicAttack
        : CombatEncounterStatus.idle;
    emit(state.copyWith(status: newStatus, target: CombatEncounterTarget.none));
    questEncounterCubit
        .toggleDarkened(newStatus == CombatEncounterStatus.idle ? false : true);
  }

  void onEnemyButtonTap(BuildContext context, int enemyIndex) {
    QuestEncounterCubit questEncounterCubit =
        context.read<QuestEncounterCubit>();
    if (state.status.isTargetSelectStatus()) {
      if (state.target.getEnemyIndex() == enemyIndex) {
        attackEnemy(context, enemyIndex);
        removeHighlightedElement(context);
      } else if (state.target == CombatEncounterTarget.all) {
        attackAllEnemies(context);
        removeHighlightedElement(context);
      } else {
        if (state.status.isTargetSelectSkillStatus()) {
          emit(state.copyWith(target: CombatEncounterTarget.all));
        } else {
          emit(state.copyWith(
              target: CombatEncounterTarget.getEnemyTarget(enemyIndex)));
        }
      }
    } else if (state.status == CombatEncounterStatus.idle) {
      emit(state.copyWith(
          status: CombatEncounterStatus.getEnemyStatus(enemyIndex)));
      questEncounterCubit.toggleDarkened(true);
    } else if (state.status ==
        CombatEncounterStatus.getEnemyStatus(enemyIndex)) {
      emit(state.copyWith(status: CombatEncounterStatus.idle));
      questEncounterCubit.toggleDarkened(false);
    } else if (state.status.isEnemyStatus()) {
      emit(state.copyWith(status: CombatEncounterStatus.idle));
      questEncounterCubit.toggleDarkened(false);
    }
  }

  void removeHighlightedElement(BuildContext context) {
    QuestEncounterCubit questEncounterCubit =
        context.read<QuestEncounterCubit>();
    emit(state.copyWith(
        status: CombatEncounterStatus.idle,
        target: CombatEncounterTarget.none));
    questEncounterCubit.toggleDarkened(false);
  }

  Future<void> attackEnemy(BuildContext context, int enemyIndex) async {
    final enemies = state.enemies;
    final enemy = enemies[enemyIndex];
    final damage = 5;
    Enemy newEnemy =
        enemy.copyWith(currentHealth: enemy.currentHealth - damage);
    if (newEnemy.currentHealth <= 0) {
      newEnemy = newEnemy.copyWith(currentHealth: 0);
    }
    await enemyRepository.updateEnemy(newEnemy);
    reloadEnemies();
  }

  Future<void> attackAllEnemies(BuildContext context) async {
    final enemies = state.enemies;
    for (var enemy in enemies) {
      final damage = 20;
      Enemy newEnemy =
          enemy.copyWith(currentHealth: enemy.currentHealth - damage);
      if (newEnemy.currentHealth <= 0) {
        newEnemy = newEnemy.copyWith(currentHealth: 0);
      }
      await enemyRepository.updateEnemy(newEnemy);
    }
    reloadEnemies();
  }
}
