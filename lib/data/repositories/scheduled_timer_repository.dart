import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:sqflite/sqflite.dart';

class ScheduledTimerRepository {
  final Database db;

  ScheduledTimerRepository({required this.db});

  // GET TIMERS BY ENCOUNTER ID
  Future<List<ScheduledTimer>> getTimersByEncounterId(
      String encounterId) async {
    final List<Map<String, dynamic>> maps = await db.query(
        ScheduledTimer.scheduledTimerTableName,
        where: '${ScheduledTimer.encounterIdColumnName} = ?',
        whereArgs: [encounterId]);
    return maps.map(_getTimerFromMap).toList();
  }

  // GET THE (AT MOST ONE) ACTIVE TIMER FOR AN OWNER + KIND
  Future<ScheduledTimer?> getTimerForOwner(
      String ownerId, ScheduledTimerKind kind) async {
    final result = await db.query(
      ScheduledTimer.scheduledTimerTableName,
      where:
          '${ScheduledTimer.ownerIdColumnName} = ? AND ${ScheduledTimer.kindColumnName} = ?',
      whereArgs: [ownerId, kind.index],
    );
    if (result.isEmpty) return null;
    return _getTimerFromMap(result.first);
  }

  // INSERT TIMER
  Future<void> insertTimer(ScheduledTimer timer) async {
    await db.insert(ScheduledTimer.scheduledTimerTableName, timer.toMap());
  }

  // UPDATE TIMER
  Future<void> updateTimer(ScheduledTimer timer) async {
    await db.update(ScheduledTimer.scheduledTimerTableName, timer.toMap(),
        where: '${ScheduledTimer.idColumnName} = ?', whereArgs: [timer.id]);
  }

  // DELETE ALL TIMERS OWNED BY A GIVEN OWNER (e.g. an enemy that died)
  Future<void> deleteTimersByOwnerId(String ownerId) async {
    await db.delete(ScheduledTimer.scheduledTimerTableName,
        where: '${ScheduledTimer.ownerIdColumnName} = ?', whereArgs: [ownerId]);
  }

  // DELETE ALL TIMERS FOR AN ENCOUNTER (e.g. on encounter completion)
  Future<void> deleteTimersByEncounterId(String encounterId) async {
    await db.delete(ScheduledTimer.scheduledTimerTableName,
        where: '${ScheduledTimer.encounterIdColumnName} = ?',
        whereArgs: [encounterId]);
  }

  // DELETE EVERY TIMER OF A GIVEN KIND, REGARDLESS OF OWNER/ENCOUNTER — e.g.
  // the "reset all skill cooldowns" admin action. Fine to be this broad
  // since there's only ever one character in local storage (see
  // CharacterRepository.getSingleCharacter) — a skillCooldown timer's
  // ownerId is always that one character's, composite-keyed with the skill
  // id (see CombatService.cooldownOwnerId), so there's no per-character
  // filtering to do here.
  Future<void> deleteTimersByKind(ScheduledTimerKind kind) async {
    await db.delete(ScheduledTimer.scheduledTimerTableName,
        where: '${ScheduledTimer.kindColumnName} = ?', whereArgs: [kind.index]);
  }

  ScheduledTimer _getTimerFromMap(Map<String, Object?> map) {
    return ScheduledTimer(
      id: map[ScheduledTimer.idColumnName] as String,
      ownerId: map[ScheduledTimer.ownerIdColumnName] as String,
      encounterId: map[ScheduledTimer.encounterIdColumnName] as String,
      kind: ScheduledTimerKind.values[map[ScheduledTimer.kindColumnName] as int],
      payload: map[ScheduledTimer.payloadColumnName] as String,
      remainingWorkMs: map[ScheduledTimer.remainingWorkMsColumnName] as int,
      segmentStartedAt: DateTime.fromMillisecondsSinceEpoch(
          map[ScheduledTimer.segmentStartedAtColumnName] as int),
      currentRate: (map[ScheduledTimer.currentRateColumnName] as num).toDouble(),
      nextTriggerAt: DateTime.fromMillisecondsSinceEpoch(
          map[ScheduledTimer.nextTriggerAtColumnName] as int),
      recurring: (map[ScheduledTimer.recurringColumnName] as int) == 1,
    );
  }
}
