import 'package:questvale/data/models/scheduled_event.dart';
import 'package:sqflite/sqflite.dart';

class ScheduledEventRepository {
  final Database db;

  ScheduledEventRepository({required this.db});

  // GET by id
  Future<ScheduledEvent> getById(String id) async {
    final scheduledEventMaps = await db.query(
      ScheduledEvent.scheduledEventTableName,
      where: '${ScheduledEvent.idColumnName} = ?',
      whereArgs: [id],
    );

    return _getScheduledEventFromMap(scheduledEventMaps[0]);
  }

  Future<ScheduledEvent> _getScheduledEventFromMap(
      Map<String, Object?> map) async {
    final ScheduledEvent scheduledEvent = ScheduledEvent();
  }
}
