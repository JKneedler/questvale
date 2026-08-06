import 'dart:math';

import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/data/providers/game_data_models/enemy_attack_data.dart';
import 'package:questvale/data/providers/game_data_models/enemy_data.dart';
import 'package:questvale/data/repositories/scheduled_timer_repository.dart';
import 'package:questvale/services/combat_service.dart';
import 'package:questvale/services/notification_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

// The result of reconciling an encounter's overdue enemy-attack timers: the
// character after every overdue attack has been applied, plus each living
// enemy's now-current (or freshly (re)armed) timer, keyed by Enemy.id.
class ReconciliationResult {
  final Character character;
  final Map<String, ScheduledTimer> attackTimersByEnemyId;

  ReconciliationResult(
      {required this.character, required this.attackTimersByEnemyId});
}

// Builds and replays ScheduledTimers (kind: enemyMove) for enemy attacks —
// the concrete engine described in the vault's "Time-Based Scheduling
// Engine" note, scoped to enemy attacks only. Pure scheduling/segment math
// lives in top-level functions/static methods so it can be unit tested
// without a database; scheduleNextMove/reconcile are the DB-touching
// wrappers around that math.
class EnemyAttackSchedulingService {
  // Copy isn't the point for this pass (per the ticket) — generic content,
  // enemy name included since it's already on hand. Not user-configurable
  // yet; a settings UI for lead time is explicitly out of scope.
  static const attackWarningLeadTime = Duration(minutes: 15);

  final Database db;
  late final ScheduledTimerRepository scheduledTimerRepository;
  late final CombatService combatService;

  EnemyAttackSchedulingService({required this.db}) {
    scheduledTimerRepository = ScheduledTimerRepository(db: db);
    combatService = CombatService(db: db);
  }

  // Weighted-random pick from an enemy's moveset using EnemyAttackData's
  // existing (previously unconsumed) `weight` field. Falls back to a
  // uniform pick if every weight is zero/negative, so a bad data entry
  // can't make move selection dead-end with no move chosen.
  static EnemyAttackData selectMove(
      List<EnemyAttackData> attacks, Random random) {
    if (attacks.isEmpty) {
      throw ArgumentError('Cannot select a move from an empty attack list');
    }
    final totalWeight = attacks.fold<double>(0, (sum, a) => sum + a.weight);
    if (totalWeight <= 0) {
      return attacks[random.nextInt(attacks.length)];
    }
    var roll = random.nextDouble() * totalWeight;
    for (final attack in attacks) {
      roll -= attack.weight;
      if (roll <= 0) return attack;
    }
    return attacks.last;
  }

  // Builds a fresh, unpersisted timer for `move` starting at `now`, at
  // 1.0x rate (no rate modifier producer exists yet). EnemyAttackData's
  // `cooldown` is in hours, matching the hours-scale cadence already
  // assumed by combat_status_card.dart's (placeholder) countdown display.
  static ScheduledTimer buildInitialTimer({
    required Enemy enemy,
    required String encounterId,
    required EnemyAttackData move,
    required DateTime now,
    required String id,
  }) {
    final remainingWorkMs = (move.cooldown * Duration.millisecondsPerHour).round();
    return ScheduledTimer(
      id: id,
      ownerId: enemy.id,
      encounterId: encounterId,
      kind: ScheduledTimerKind.enemyMove,
      payload: move.name,
      remainingWorkMs: remainingWorkMs,
      segmentStartedAt: now,
      currentRate: 1.0,
      nextTriggerAt: now.add(Duration(milliseconds: remainingWorkMs)),
      recurring: false,
    );
  }

  // Closes the timer's current segment as of `at` (progress made under its
  // existing currentRate) and opens a new one under `newRate`, recomputing
  // nextTriggerAt from there. Nothing in production calls this with a rate
  // other than 1.0 yet (no Slow/Freeze producer exists), but the math is
  // written generically per the architecture note so a future rate-modifier
  // producer can plug in without touching this engine's core.
  static ScheduledTimer recomputeSegment({
    required ScheduledTimer timer,
    required double newRate,
    required DateTime at,
  }) {
    final elapsedInSegmentMs = at.difference(timer.segmentStartedAt).inMilliseconds;
    final consumedMs = (elapsedInSegmentMs * timer.currentRate).round();
    final remainingWorkMs = max(0, timer.remainingWorkMs - consumedMs);
    // A rate of 0 (e.g. a future Freeze) halts the timer entirely rather
    // than firing it — represented as an effectively-unreachable deadline
    // rather than dividing by zero.
    final wallClockForRemainder = newRate <= 0
        ? const Duration(days: 3650)
        : Duration(milliseconds: (remainingWorkMs / newRate).round());
    return timer.copyWith(
      remainingWorkMs: remainingWorkMs,
      segmentStartedAt: at,
      currentRate: newRate,
      nextTriggerAt: at.add(wallClockForRemainder),
    );
  }

  // Finds the single soonest overdue timer (nextTriggerAt <= now) across
  // `timers`, or null if nothing is due. The core of the chronological
  // replay requirement — reconcile() calls this once per iteration rather
  // than resolving every overdue timer against a single elapsed-time
  // subtraction, so multiple overdue events always process oldest-first.
  static ScheduledTimer? nextDueTimer(List<ScheduledTimer> timers, DateTime now) {
    final due = timers.where((t) => !t.nextTriggerAt.isAfter(now)).toList()
      ..sort((a, b) => a.nextTriggerAt.compareTo(b.nextTriggerAt));
    return due.isEmpty ? null : due.first;
  }

  // Picks a move for `enemy` and persists a fresh timer for it, replacing
  // any stale one that owner already had (e.g. re-arming after an attack).
  // Also (re)schedules the attack-incoming notification for this timer —
  // this is the single choke point used for both initial spawn scheduling
  // and every re-arm, so timer and notification lifecycles always match.
  Future<ScheduledTimer> scheduleNextMove({
    required Enemy enemy,
    required EnemyData enemyData,
    required Encounter encounter,
    DateTime? from,
    Random? random,
  }) async {
    final move = selectMove(enemyData.attacks, random ?? Random());
    final timer = buildInitialTimer(
      enemy: enemy,
      encounterId: encounter.id,
      move: move,
      now: from ?? DateTime.now(),
      id: Uuid().v4(),
    );
    final existing = await scheduledTimerRepository.getTimerForOwner(
        enemy.id, ScheduledTimerKind.enemyMove);
    final ScheduledTimer persisted;
    if (existing != null) {
      persisted = timer.copyWith(id: existing.id);
      await scheduledTimerRepository.updateTimer(persisted);
    } else {
      persisted = timer;
      await scheduledTimerRepository.insertTimer(persisted);
    }
    await NotificationService().scheduleEnemyAttackWarning(
      persisted,
      leadTime: attackWarningLeadTime,
      title: 'Enemy Attack Incoming',
      body: '${enemyData.name} is about to attack!',
    );
    return persisted;
  }

  // The replay engine: processes each living enemy's overdue ScheduledTimer
  // (nextTriggerAt has passed), applying damage and re-arming its next move
  // chained from `now` — not from the missed deadline. That cap is
  // deliberate: an enemy resolves at most one attack per reconcile() call
  // no matter how long the app was closed, so a missed day (or several)
  // costs exactly one hit rather than compounding every elapsed cooldown
  // cycle into a pile of damage the moment the player returns. It's also
  // what guarantees at most one ScheduledTimer — and so at most one
  // attack-incoming notification — is ever pending per enemy at a time.
  // Multiple simultaneously-overdue enemies are still each resolved, still
  // soonest-first via nextDueTimer(). Safe to call on every load — a no-op
  // when nothing is overdue.
  Future<ReconciliationResult> reconcile({
    required Encounter encounter,
    required Character character,
    required EnemyData? Function(Enemy enemy) enemyDataFor,
    Random? random,
  }) async {
    final enemiesById = {for (final e in encounter.enemies) e.id: e};
    var timers = await scheduledTimerRepository.getTimersByEncounterId(encounter.id);
    var currentCharacter = character;
    final now = DateTime.now();

    // Self-heals any living enemy with no timer at all — e.g. an encounter
    // already in progress when this feature shipped, so spawn-time
    // scheduling never ran for it. Scheduled from `now` since there's no
    // missed deadline to chain from.
    final ownedIds = timers.map((t) => t.ownerId).toSet();
    for (final enemy in encounter.enemies) {
      if (enemy.currentHealth <= 0 || ownedIds.contains(enemy.id)) continue;
      final enemyData = enemyDataFor(enemy);
      if (enemyData == null || enemyData.attacks.isEmpty) continue;
      final timer = await scheduleNextMove(
        enemy: enemy,
        enemyData: enemyData,
        encounter: encounter,
        from: now,
        random: random,
      );
      timers = [...timers, timer];
    }

    while (true) {
      final due = nextDueTimer(timers, now);
      if (due == null) break;
      final enemy = enemiesById[due.ownerId];
      timers = timers.where((t) => t.id != due.id).toList();

      if (enemy == null || enemy.currentHealth <= 0) {
        // Dead/missing enemies don't get to land a last hit from a stale
        // timer — just clear it (and any warning notification riding on it).
        await NotificationService().cancelEnemyAttackWarning(due.id);
        await scheduledTimerRepository.deleteTimersByOwnerId(due.ownerId);
        continue;
      }

      final enemyData = enemyDataFor(enemy);
      if (enemyData == null || enemyData.attacks.isEmpty) {
        await NotificationService().cancelEnemyAttackWarning(due.id);
        await scheduledTimerRepository.deleteTimersByOwnerId(due.ownerId);
        continue;
      }
      final attack = enemyData.attacks.firstWhere(
        (a) => a.name == due.payload,
        orElse: () => enemyData.attacks.first,
      );

      currentCharacter =
          await combatService.applyEnemyAttackDamage(attack, currentCharacter);

      // Chain from `now`, not the missed deadline — see the reconcile()
      // doc-comment. This is what caps the enemy to one resolved attack per
      // reconcile() call regardless of how overdue it was.
      final nextTimer = await scheduleNextMove(
        enemy: enemy,
        enemyData: enemyData,
        encounter: encounter,
        from: now,
        random: random,
      );
      timers = [...timers, nextTimer];
    }

    return ReconciliationResult(
      character: currentCharacter,
      attackTimersByEnemyId: {for (final t in timers) t.ownerId: t},
    );
  }
}
