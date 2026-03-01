import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/enemy.dart';

enum CombatStatus {
  idle,
  inspectingPlayer,
  inspectingEnemy,
  targetingSkill,
  playingSkillAnimation,
  complete,
}

enum SkillTarget {
  none,
  self,
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

  static SkillTarget getEnemyTarget(int enemyIndex) {
    return [
      enemy1,
      enemy2,
      enemy3,
    ][enemyIndex];
  }
}

class CombatState extends Equatable {
  final List<Enemy> enemies;
  final CombatStatus status;
  final SkillTarget target;
  final int targetingSkillIndex;
  final int inspectingEnemyIndex;

  const CombatState({
    required this.enemies,
    this.status = CombatStatus.idle,
    this.target = SkillTarget.none,
    this.targetingSkillIndex = -1,
    this.inspectingEnemyIndex = -1,
  });

  CombatState copyWith({
    List<Enemy>? enemies,
    CombatStatus? status,
    SkillTarget? target,
    int? targetingSkillIndex,
    int? inspectingEnemyIndex,
  }) {
    return CombatState(
        enemies: enemies ?? this.enemies,
        status: status ?? this.status,
        target: target ?? this.target,
        targetingSkillIndex: targetingSkillIndex ?? this.targetingSkillIndex,
        inspectingEnemyIndex:
            inspectingEnemyIndex ?? this.inspectingEnemyIndex);
  }

  @override
  List<Object?> get props =>
      [enemies, status, target, targetingSkillIndex, inspectingEnemyIndex];
}
