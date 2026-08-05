import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/data/skills/base_active_skill.dart';

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
  final BaseActiveSkill? targetingSkill;
  final int inspectingEnemyIndex;

  // Real enemy-attack timers for this encounter, keyed by Enemy.id —
  // reloaded alongside enemies in CombatCubit.reload().
  final Map<String, ScheduledTimer> attackTimers;

  const CombatState({
    required this.enemies,
    this.status = CombatStatus.idle,
    this.target = SkillTarget.none,
    this.targetingSkill,
    this.inspectingEnemyIndex = -1,
    this.attackTimers = const {},
  });

  ScheduledTimer? attackTimerFor(Enemy enemy) => attackTimers[enemy.id];

  CombatState copyWith({
    List<Enemy>? enemies,
    CombatStatus? status,
    SkillTarget? target,
    BaseActiveSkill? targetingSkill,
    int? inspectingEnemyIndex,
    Map<String, ScheduledTimer>? attackTimers,
  }) {
    return CombatState(
        enemies: enemies ?? this.enemies,
        status: status ?? this.status,
        target: target ?? this.target,
        targetingSkill: targetingSkill ?? this.targetingSkill,
        inspectingEnemyIndex:
            inspectingEnemyIndex ?? this.inspectingEnemyIndex,
        attackTimers: attackTimers ?? this.attackTimers);
  }

  @override
  List<Object?> get props => [
        enemies,
        status,
        target,
        targetingSkill,
        inspectingEnemyIndex,
        attackTimers
      ];
}
