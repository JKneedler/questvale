// The shared time-based scheduling primitive — see the vault's
// "Time-Based Scheduling Engine" architecture note. One record shape
// covers enemy moves, status effect duration/ticks, and player skill
// cooldowns — but each kind is reconciled by its own owning service
// (EnemyAttackSchedulingService for enemyMove, StatusEffectService for the
// statusEffect* kinds), not one unified dispatcher yet, since only two
// non-enemyMove kinds exist so far. Every reconcile() implementation MUST
// filter its fetched timers down to the kind(s) it actually knows how to
// handle before processing — timers of every kind sharing one table and one
// per-encounter query means an unfiltered reconcile() will eventually pull
// in a kind it wasn't written for.
enum ScheduledTimerKind {
  enemyMove,
  skillCooldown,
  // Recurring — re-arms itself each tick until its owning effect's
  // duration is exhausted (Burn). See StatusEffectService.
  statusEffectTick,
  // One-shot — fires once to remove an effect that doesn't tick (Slow).
  // See StatusEffectService.
  statusEffectExpiry;
}

class ScheduledTimer {
  static const String scheduledTimerTableName = 'ScheduledTimers';

  static const String idColumnName = 'id';
  static const String ownerIdColumnName = 'ownerId';
  static const String encounterIdColumnName = 'encounterId';
  static const String kindColumnName = 'kind';
  static const String payloadColumnName = 'payload';
  static const String remainingWorkMsColumnName = 'remainingWorkMs';
  static const String segmentStartedAtColumnName = 'segmentStartedAt';
  static const String currentRateColumnName = 'currentRate';
  static const String nextTriggerAtColumnName = 'nextTriggerAt';
  static const String recurringColumnName = 'recurring';

  static const createTableSQL = '''
    CREATE TABLE $scheduledTimerTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $ownerIdColumnName VARCHAR NOT NULL,
      $encounterIdColumnName VARCHAR NOT NULL,
      $kindColumnName INTEGER NOT NULL,
      $payloadColumnName VARCHAR NOT NULL,
      $remainingWorkMsColumnName INTEGER NOT NULL,
      $segmentStartedAtColumnName INTEGER NOT NULL,
      $currentRateColumnName REAL NOT NULL DEFAULT 1.0,
      $nextTriggerAtColumnName INTEGER NOT NULL,
      $recurringColumnName INTEGER NOT NULL DEFAULT 0
    );
  ''';

  final String id;
  final String ownerId;
  final String encounterId;
  final ScheduledTimerKind kind;
  final String payload;
  final int remainingWorkMs;
  final DateTime segmentStartedAt;
  final double currentRate;
  final DateTime nextTriggerAt;
  final bool recurring;

  const ScheduledTimer({
    required this.id,
    required this.ownerId,
    required this.encounterId,
    required this.kind,
    required this.payload,
    required this.remainingWorkMs,
    required this.segmentStartedAt,
    this.currentRate = 1.0,
    required this.nextTriggerAt,
    this.recurring = false,
  });

  Map<String, Object?> toMap() {
    return {
      idColumnName: id,
      ownerIdColumnName: ownerId,
      encounterIdColumnName: encounterId,
      kindColumnName: kind.index,
      payloadColumnName: payload,
      remainingWorkMsColumnName: remainingWorkMs,
      segmentStartedAtColumnName: segmentStartedAt.millisecondsSinceEpoch,
      currentRateColumnName: currentRate,
      nextTriggerAtColumnName: nextTriggerAt.millisecondsSinceEpoch,
      recurringColumnName: recurring ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'ScheduledTimer(id: $id, ownerId: $ownerId, encounterId: $encounterId, kind: $kind, payload: $payload, remainingWorkMs: $remainingWorkMs, segmentStartedAt: $segmentStartedAt, currentRate: $currentRate, nextTriggerAt: $nextTriggerAt, recurring: $recurring)';
  }

  ScheduledTimer copyWith({
    String? id,
    String? ownerId,
    String? encounterId,
    ScheduledTimerKind? kind,
    String? payload,
    int? remainingWorkMs,
    DateTime? segmentStartedAt,
    double? currentRate,
    DateTime? nextTriggerAt,
    bool? recurring,
  }) {
    return ScheduledTimer(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      encounterId: encounterId ?? this.encounterId,
      kind: kind ?? this.kind,
      payload: payload ?? this.payload,
      remainingWorkMs: remainingWorkMs ?? this.remainingWorkMs,
      segmentStartedAt: segmentStartedAt ?? this.segmentStartedAt,
      currentRate: currentRate ?? this.currentRate,
      nextTriggerAt: nextTriggerAt ?? this.nextTriggerAt,
      recurring: recurring ?? this.recurring,
    );
  }
}
