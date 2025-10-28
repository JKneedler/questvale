import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/character_data_cubit.dart';
import 'package:questvale/cubits/town_tab/questing/combat_encounter/combat_encounter_state.dart';
import 'package:questvale/cubits/town_tab/questing/quest_encounter/quest_encounter_cubit.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:questvale/data/repositories/encounter_repository.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/services/combat_service.dart';
import 'package:sqflite/sqflite.dart';

class CombatEncounterCubit extends Cubit<CombatEncounterState> {
  final Encounter encounter;
  final Character character;
  late CharacterRepository characterRepository;
  late EncounterRepository encounterRepository;
  late EnemyRepository enemyRepository;
  late CombatService combatService;

  CombatEncounterCubit(
      {required this.encounter, required this.character, required Database db})
      : super(CombatEncounterState(enemies: [])) {
    enemyRepository = EnemyRepository(db: db);
    characterRepository = CharacterRepository(db: db);
    encounterRepository = EncounterRepository(db: db);
    combatService = CombatService(db: db);
    init();
  }

  Future<void> init() async {
    await reload();
  }

  Future<void> reload() async {
    final combatStats = await combatService.getCharacterCombatStats(character);
    print('combatStats: ${combatStats.toString()}');
    final enemies = await enemyRepository.getEnemiesByEncounterId(encounter.id);
    if (!isClosed && state.status != CombatEncounterStatus.complete) {
      if (enemies.every((enemy) => enemy.currentHealth <= 0)) {
        emit(state
            .copyWith(status: CombatEncounterStatus.complete, enemies: []));
      } else {
        emit(state.copyWith(enemies: enemies));
      }
    }
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
    final combatStats = context.read<CharacterDataCubit>().state.combatStats;
    if (state.status.isTargetSelectStatus()) {
      if (state.target.getEnemyIndex() == enemyIndex) {
        if (state.status == CombatEncounterStatus.targetSelectBasicAttack) {
          attackEnemy(
              context, enemyIndex, combatStats?.physicalBaseDamage ?? 0);
        } else {
          // Skill attack
          attackEnemy(context, enemyIndex, 20);
        }
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

  Future<void> attackEnemy(
      BuildContext context, int enemyIndex, int damage) async {
    final enemies = state.enemies;
    final enemy = enemies[enemyIndex];
    Enemy newEnemy =
        enemy.copyWith(currentHealth: enemy.currentHealth - damage);
    if (newEnemy.currentHealth <= 0) {
      newEnemy = newEnemy.copyWith(currentHealth: 0);
    }
    await enemyRepository.updateEnemy(newEnemy);
    reload();
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
    reload();
  }
}
