import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/enemy.dart';

enum CombatEncounterStatus {
  idle,
  inspectingEnemy1,
  inspectingEnemy2,
  inspectingEnemy3,
  targetSelectBasicAttack,
  targetSelectSkill1,
  targetSelectSkill2,
  targetSelectSkill3,
  targetSelectSkill4,
  attackingBasicAttack,
  attackingSkill1,
  attackingSkill2,
  attackingSkill3,
  attackingSkill4,
  complete;

  static CombatEncounterStatus getSkillStatus(int skillIndex) {
    return [
      targetSelectSkill1,
      targetSelectSkill2,
      targetSelectSkill3,
      targetSelectSkill4,
    ][skillIndex];
  }

  static CombatEncounterStatus getEnemyStatus(int enemyIndex) {
    return [
      inspectingEnemy1,
      inspectingEnemy2,
      inspectingEnemy3,
    ][enemyIndex];
  }

  int getEnemyIndex() {
    return [
      inspectingEnemy1,
      inspectingEnemy2,
      inspectingEnemy3,
    ].indexOf(this);
  }

  bool isEnemyStatus() {
    return [
      inspectingEnemy1,
      inspectingEnemy2,
      inspectingEnemy3,
    ].contains(this);
  }

  bool isTargetSelectStatus() {
    return [
      targetSelectBasicAttack,
      targetSelectSkill1,
      targetSelectSkill2,
      targetSelectSkill3,
      targetSelectSkill4,
    ].contains(this);
  }

  bool isTargetSelectSkillStatus() {
    return [
      targetSelectSkill1,
      targetSelectSkill2,
      targetSelectSkill3,
      targetSelectSkill4,
    ].contains(this);
  }

  bool isAttackStatus() {
    return [
      attackingBasicAttack,
      attackingSkill1,
      attackingSkill2,
      attackingSkill3,
      attackingSkill4,
    ].contains(this);
  }
}

enum CombatEncounterTarget {
  none,
  enemy1,
  enemy2,
  enemy3,
  all;

  int getEnemyIndex() {
    return [
      enemy1,
      enemy2,
      enemy3,
    ].indexOf(this);
  }

  static CombatEncounterTarget getEnemyTarget(int enemyIndex) {
    return [
      enemy1,
      enemy2,
      enemy3,
    ][enemyIndex];
  }
}

class CombatEncounterState extends Equatable {
  final List<Enemy> enemies;
  final CombatEncounterStatus status;
  final CombatEncounterTarget target;
  final bool firstPlay;

  const CombatEncounterState({
    required this.enemies,
    this.status = CombatEncounterStatus.idle,
    this.target = CombatEncounterTarget.none,
    this.firstPlay = false,
  });

  CombatEncounterState copyWith({
    List<Enemy>? enemies,
    CombatEncounterStatus? status,
    CombatEncounterTarget? target,
    bool? firstPlay,
  }) {
    return CombatEncounterState(
      enemies: enemies ?? this.enemies,
      status: status ?? this.status,
      target: target ?? this.target,
      firstPlay: firstPlay ?? this.firstPlay,
    );
  }

  @override
  List<Object?> get props => [enemies, status, target, firstPlay];
}
