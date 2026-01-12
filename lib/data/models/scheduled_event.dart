import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/enemy.dart';

enum ScheduledEventType {
  enemyAttack,
  playerStatusTrigger,
  playerStatusExpire,
  enemyStatusTrigger,
  enemyStatusExpire,
}

class ScheduledEvent {
  static const scheduledEventTableName = 'ScheduledEvents';

  static const String idColumnName = 'id';
  static const String characterColumnName = 'character';
  static const String typeColumnName = 'type';
  static const String runAtColumnName = 'runAt';
  static const String enemyColumnName = 'enemy';
  //static const String statusColumnName = 'status';

  static const String createTableSQL = '''
    CREATE TABLE ${ScheduledEvent.scheduledEventTableName} (
      ${ScheduledEvent.idColumnName} VARCHAR PRIMARY KEY,
      ${ScheduledEvent.characterColumnName} VARCHAR NOT NULL,
      ${ScheduledEvent.typeColumnName} INTEGER NOT NULL,
      ${ScheduledEvent.runAtColumnName} DATETIME NOT NULL,
      ${ScheduledEvent.enemyColumnName} VARCHAR
    );
  ''';

  final String id;
  final Character character;
  final ScheduledEventType type;
  final DateTime runAt;
  final Enemy? enemy;

  ScheduledEvent({
    required this.id,
    required this.character,
    required this.type,
    required this.runAt,
    this.enemy,
  });

  Map<String, Object?> toMap() {
    return {
      ScheduledEvent.idColumnName: id,
      ScheduledEvent.characterColumnName: character.id,
      ScheduledEvent.typeColumnName: type.index,
      ScheduledEvent.runAtColumnName: runAt.toString(),
      ScheduledEvent.enemyColumnName: enemy?.id,
    };
  }

  @override
  String toString() {
    return 'ScheduledEvent { id: $id, character: ${character.id}, type: ${type.toString()}, runAt: $runAt, enemy: ${enemy?.id} }';
  }

  ScheduledEvent copyWith({
    Character? character,
    ScheduledEventType? type,
    DateTime? runAt,
    Enemy? enemy,
  }) {
    return ScheduledEvent(
      id: id,
      character: character ?? this.character,
      type: type ?? this.type,
      runAt: runAt ?? this.runAt,
      enemy: enemy ?? this.enemy,
    );
  }
}
