import 'dart:math';

import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/data/models/status_effect_instance.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:questvale/data/repositories/scheduled_timer_repository.dart';
import 'package:questvale/data/repositories/status_effect_repository.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/services/combat_service.dart';
import 'package:questvale/services/enemy_attack_scheduling_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

// Result of merging a new Burn application into whatever's already banked
// — see mergeBurnApplication's doc comment for the formula.
class BurnMergeResult {
  final int remainingMs;
  final int stacks;

  const BurnMergeResult({required this.remainingMs, required this.stacks});
}

// Applies and reconciles status effects (Burn, Slow so far — see the
// vault's Status Effects note and the Skill System Foundations ticket,
// subtask 3). Same split as every other service in this codebase: pure
// computation in static methods, unit testable without a database (see
// status_effect_service_test.dart); DB-touching orchestration on the
// instance.
//
// Deliberately depends on EnemyRepository/ScheduledTimerRepository/
// StatusEffectRepository directly rather than a full CombatService —
// CombatService owns a StatusEffectService (skills reach this through
// `combatService.statusEffectService`), so the reverse dependency would be
// circular. Damage math is shared with CombatService via the pure static
// CombatService.resolveDamageAgainstEnemy instead.
class StatusEffectService {
  // Burn's tick cadence — intrinsic to what "Burn" means (vault: "deals
  // damage every 30 minutes"), not a per-skill knob, so it lives here
  // rather than on Firebolt.
  static const burnTickInterval = Duration(minutes: 30);
  // Slow's rate multiplier — vault: "flat 50%, regardless of source or
  // tier". Same reasoning as burnTickInterval above.
  static const slowRateMultiplier = 0.5;

  final Database db;
  late EnemyRepository enemyRepository;
  late ScheduledTimerRepository scheduledTimerRepository;
  late StatusEffectRepository statusEffectRepository;

  StatusEffectService({required this.db}) {
    enemyRepository = EnemyRepository(db: db);
    scheduledTimerRepository = ScheduledTimerRepository(db: db);
    statusEffectRepository = StatusEffectRepository(db: db);
  }

  // A composite owner id so one target can carry several different
  // ticking/expiring effects at once under ScheduledTimerRepository's
  // existing one-timer-per-(ownerId, kind) shape — same trick
  // CombatService.cooldownOwnerId uses for skill cooldowns.
  static String timerOwnerId(String targetId, StatusEffectType effectType) =>
      '$targetId:${effectType.name}';

  static String targetIdFromTimerOwnerId(String ownerId) =>
      ownerId.split(':').first;

  // The vault's Burn weighted-merge rule, verbatim:
  //   newRemaining = (oldRemaining × oldStacks + applicationDuration × newStacks) / (oldStacks + newStacks)
  //   newStackCount = oldStacks + newStacks
  // Degenerates correctly to a fresh full-duration application when
  // oldStacks is 0 (the oldRemaining×oldStacks term vanishes regardless of
  // oldRemaining's value) — callers don't need a separate fresh-vs-reapply
  // branch. Pure — no DB.
  static BurnMergeResult mergeBurnApplication({
    required int oldRemainingMs,
    required int oldStacks,
    required int applicationDurationMs,
    required int newStacks,
  }) {
    final totalStacks = oldStacks + newStacks;
    if (totalStacks <= 0) {
      return const BurnMergeResult(remainingMs: 0, stacks: 0);
    }
    final remainingMs =
        ((oldRemainingMs * oldStacks) + (applicationDurationMs * newStacks)) ~/
            totalStacks;
    return BurnMergeResult(remainingMs: remainingMs, stacks: totalStacks);
  }

  // Builds (or re-arms, reusing `id`) the single recurring timer that
  // drives a target's Burn — its next tick fires at min(tick interval,
  // however much duration is left), so a Burn with less than 30 minutes
  // remaining ticks exactly once more, right at expiry, rather than
  // overshooting. Pure — no DB.
  static ScheduledTimer buildBurnTimer({
    required String targetId,
    required String encounterId,
    required int remainingMs,
    required DateTime now,
    required String id,
  }) {
    final msUntilNextTick = min(burnTickInterval.inMilliseconds, remainingMs);
    return ScheduledTimer(
      id: id,
      ownerId: timerOwnerId(targetId, StatusEffectType.burn),
      encounterId: encounterId,
      kind: ScheduledTimerKind.statusEffectTick,
      payload: StatusEffectType.burn.name,
      remainingWorkMs: remainingMs,
      segmentStartedAt: now,
      currentRate: 1.0,
      nextTriggerAt: now.add(Duration(milliseconds: msUntilNextTick)),
      recurring: true,
    );
  }

  // One-shot expiry timer for a non-ticking effect (Slow so far). Pure —
  // no DB.
  static ScheduledTimer buildExpiryTimer({
    required String targetId,
    required StatusEffectType effectType,
    required String encounterId,
    required int durationMs,
    required DateTime now,
    required String id,
  }) {
    return ScheduledTimer(
      id: id,
      ownerId: timerOwnerId(targetId, effectType),
      encounterId: encounterId,
      kind: ScheduledTimerKind.statusEffectExpiry,
      payload: effectType.name,
      remainingWorkMs: durationMs,
      segmentStartedAt: now,
      currentRate: 1.0,
      nextTriggerAt: now.add(Duration(milliseconds: durationMs)),
      recurring: false,
    );
  }

  // Firebolt's reference case (see the ticket) — rolls a Burn application
  // onto `targetId`, merging into whatever's already banked per the
  // vault's weighted-merge rule. `tickDamage` is the caster's
  // already-resolved flat per-stack-per-tick damage — a snapshot of the
  // caster's attack power at cast time (see Firebolt.execute), not
  // re-derived here or at tick time.
  Future<void> applyBurn({
    required String targetId,
    required String encounterId,
    required int tickDamage,
    required Duration applicationDuration,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final existingInstance = await statusEffectRepository.getInstance(
        targetId, StatusEffectType.burn);
    final ownerId = timerOwnerId(targetId, StatusEffectType.burn);
    final existingTimer = await scheduledTimerRepository.getTimerForOwner(
        ownerId, ScheduledTimerKind.statusEffectTick);

    // recomputeSegment (not just reading remainingWorkMs off the stale
    // row) accounts for however much of the current tick has already
    // elapsed — same engine EnemyAttackSchedulingService uses for enemy
    // moves, reused rather than reimplemented.
    final oldRemainingMs = existingTimer == null
        ? 0
        : EnemyAttackSchedulingService.recomputeSegment(
                timer: existingTimer, newRate: 1.0, at: at)
            .remainingWorkMs;

    final merged = mergeBurnApplication(
      oldRemainingMs: oldRemainingMs,
      oldStacks: existingInstance?.stacks ?? 0,
      applicationDurationMs: applicationDuration.inMilliseconds,
      newStacks: 1,
    );

    await statusEffectRepository.upsertInstance(StatusEffectInstance(
      ownerId: targetId,
      effectType: StatusEffectType.burn,
      stacks: merged.stacks,
      magnitude: tickDamage.toDouble(),
    ));

    final timer = buildBurnTimer(
      targetId: targetId,
      encounterId: encounterId,
      remainingMs: merged.remainingMs,
      now: at,
      id: existingTimer?.id ?? const Uuid().v4(),
    );
    if (existingTimer != null) {
      await scheduledTimerRepository.updateTimer(timer);
    } else {
      await scheduledTimerRepository.insertTimer(timer);
    }
  }

  // Frost Shard's reference case (see the ticket) — applies Slow to
  // `targetId`, halving the consumption rate of its `affectedTimerKind`
  // timer (enemyMove for an enemy target — Slow only ever targets enemies
  // so far, nothing casts it at a player yet) for `duration`. Reapplying
  // just refreshes the duration to a fresh full value — Slow doesn't stack
  // or weighted-merge like Burn (it's a flat, non-scaling rate modifier
  // per the vault, not a DoT).
  Future<void> applySlow({
    required String targetId,
    required String encounterId,
    required ScheduledTimerKind affectedTimerKind,
    required Duration duration,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final ownerId = timerOwnerId(targetId, StatusEffectType.slow);
    final existingTimer = await scheduledTimerRepository.getTimerForOwner(
        ownerId, ScheduledTimerKind.statusEffectExpiry);

    await statusEffectRepository.upsertInstance(StatusEffectInstance(
      ownerId: targetId,
      effectType: StatusEffectType.slow,
      stacks: 1,
      magnitude: slowRateMultiplier,
    ));

    final timer = buildExpiryTimer(
      targetId: targetId,
      effectType: StatusEffectType.slow,
      encounterId: encounterId,
      durationMs: duration.inMilliseconds,
      now: at,
      id: existingTimer?.id ?? const Uuid().v4(),
    );
    if (existingTimer != null) {
      await scheduledTimerRepository.updateTimer(timer);
    } else {
      await scheduledTimerRepository.insertTimer(timer);
    }

    await _setRate(targetId, affectedTimerKind, slowRateMultiplier, at);
  }

  // Applies `newRate` to whatever timer of `kind` the target currently
  // has, if any — scoped by ownerId AND kind, per the vault's Time-Based
  // Scheduling Engine note, so this only ever touches the one timer Slow
  // is actually meant to affect. A target with no such timer yet (e.g. an
  // enemy whose move hasn't been scheduled) is a silent no-op — nothing to
  // slow yet, but the StatusEffectInstance/expiry timer above still exist
  // so a later move-scheduling pass (or a future UI) can still see Slow is
  // active.
  Future<void> _setRate(
      String targetId, ScheduledTimerKind kind, double rate, DateTime at) async {
    final timer =
        await scheduledTimerRepository.getTimerForOwner(targetId, kind);
    if (timer == null) return;
    final updated = EnemyAttackSchedulingService.recomputeSegment(
        timer: timer, newRate: rate, at: at);
    await scheduledTimerRepository.updateTimer(updated);
  }

  // Processes every due statusEffectTick/statusEffectExpiry timer for this
  // encounter, oldest-first (reusing EnemyAttackSchedulingService's
  // kind-agnostic nextDueTimer picker rather than a second copy of that
  // math). Ticks resolve at most one tick per call, chained from `now`
  // rather than the missed deadline — same "don't punish time away"
  // reasoning EnemyAttackSchedulingService.reconcile documents for enemy
  // moves, applied here so a week-long absence doesn't return a stack of
  // catch-up Burn damage all at once.
  Future<void> reconcile({
    required Encounter encounter,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    var timers = (await scheduledTimerRepository
            .getTimersByEncounterId(encounter.id))
        .where((t) =>
            t.kind == ScheduledTimerKind.statusEffectTick ||
            t.kind == ScheduledTimerKind.statusEffectExpiry)
        .toList();

    while (true) {
      final due = EnemyAttackSchedulingService.nextDueTimer(timers, at);
      if (due == null) break;
      timers = timers.where((t) => t.id != due.id).toList();

      if (due.kind == ScheduledTimerKind.statusEffectTick) {
        await _resolveTick(due, at);
      } else {
        await _resolveExpiry(due, at);
      }
    }
  }

  Future<void> _resolveTick(ScheduledTimer due, DateTime at) async {
    if (due.payload != StatusEffectType.burn.name) {
      // No other tick-based effect exists yet — an unrecognized payload
      // means stale data from a removed effect type; drop it rather than
      // looping on it forever.
      await scheduledTimerRepository.deleteTimersByOwnerId(due.ownerId);
      return;
    }

    final targetId = targetIdFromTimerOwnerId(due.ownerId);
    final instance = await statusEffectRepository.getInstance(
        targetId, StatusEffectType.burn);
    if (instance == null) {
      // Instance already gone (e.g. the enemy died and was cleaned up by
      // some other path) — just drop the stale timer.
      await scheduledTimerRepository.deleteTimersByOwnerId(due.ownerId);
      return;
    }

    // The tick that just fired always deals its damage first — "all
    // stacks deplete together when the duration runs out" (vault) means
    // the final tick still lands, it just isn't followed by another one.
    final tickDamage = (instance.magnitude * instance.stacks).round();
    final enemy = await enemyRepository.getEnemyById(targetId);
    final resolved =
        CombatService.resolveDamageAgainstEnemy(tickDamage, enemy);
    await enemyRepository.updateEnemy(resolved.updatedEnemy);

    final remainingAfterTick =
        due.remainingWorkMs - burnTickInterval.inMilliseconds;
    if (resolved.result.didKill || remainingAfterTick <= 0) {
      await statusEffectRepository.deleteInstance(
          targetId, StatusEffectType.burn);
      await scheduledTimerRepository.deleteTimersByOwnerId(due.ownerId);
      return;
    }

    final rearmed = buildBurnTimer(
      targetId: targetId,
      encounterId: due.encounterId,
      remainingMs: remainingAfterTick,
      now: at,
      id: due.id,
    );
    await scheduledTimerRepository.updateTimer(rearmed);
  }

  Future<void> _resolveExpiry(ScheduledTimer due, DateTime at) async {
    final targetId = targetIdFromTimerOwnerId(due.ownerId);
    final effectType = StatusEffectType.values.firstWhere(
        (t) => t.name == due.payload,
        orElse: () => StatusEffectType.slow);

    if (effectType == StatusEffectType.slow) {
      // Revert to full speed — only one rate modifier exists this pass, so
      // there's no "strongest remaining modifier" comparison to make yet
      // (see the vault's Rate-Modifier Stacking section — that's a Freeze
      // concern, and Freeze isn't built this pass).
      await _setRate(targetId, ScheduledTimerKind.enemyMove, 1.0, at);
    }

    await statusEffectRepository.deleteInstance(targetId, effectType);
    await scheduledTimerRepository.deleteTimersByOwnerId(due.ownerId);
  }
}
