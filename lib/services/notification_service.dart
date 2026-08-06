import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/data/models/todo_reminder.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Singleton — the underlying plugin is initialized once from main.dart
// before runApp, then reused by whichever cubit needs to schedule/cancel a
// reminder notification.
class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  static const _androidChannelId = 'todo_reminders';
  static const _androidChannelName = 'Task & Habit Reminders';

  static const _enemyAttackChannelId = 'enemy_attack_warnings';
  static const _enemyAttackChannelName = 'Enemy Attack Warnings';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(initSettings);

    // iOS/macOS request permission as part of initialize() above (default
    // DarwinInitializationSettings already requests alert/sound/badge).
    // Android 13+ needs an explicit runtime request.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> scheduleReminder(
    TodoReminder reminder, {
    required String title,
    String? body,
  }) async {
    if (reminder.dateTime.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      _notificationId(reminder.id),
      title,
      body,
      // TZDateTime.from converts by absolute instant, not by reinterpreting
      // the wall-clock fields — so this fires at the correct moment
      // regardless of device timezone without needing to know its name.
      tz.TZDateTime.from(reminder.dateTime, tz.UTC),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: 'Reminders for your Tasks and Habits',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // Reminders don't need to-the-second precision, so inexact avoids
      // requiring Android's SCHEDULE_EXACT_ALARM permission (a special
      // user-granted-in-Settings permission on Android 12+).
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(String reminderId) async {
    await _plugin.cancel(_notificationId(reminderId));
  }

  // Warns before an enemy's ScheduledTimer (see EnemyAttackSchedulingService)
  // fires. Reconciliation caps an enemy to at most one pending timer at a
  // time and always chains its id forward across re-arms (see
  // scheduleNextMove), so scheduling under `timer.id` here naturally
  // replaces the previous warning for that enemy — no separate bookkeeping
  // needed to know "does this enemy already have one scheduled."
  Future<void> scheduleEnemyAttackWarning(
    ScheduledTimer timer, {
    required Duration leadTime,
    required String title,
    String? body,
  }) async {
    final fireAt = timer.nextTriggerAt.subtract(leadTime);
    if (fireAt.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      _notificationId(timer.id),
      title,
      body,
      tz.TZDateTime.from(fireAt, tz.UTC),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _enemyAttackChannelId,
          _enemyAttackChannelName,
          channelDescription: 'Warnings before an enemy attacks',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelEnemyAttackWarning(String timerId) async {
    await _plugin.cancel(_notificationId(timerId));
  }

  int _notificationId(String id) => id.hashCode & 0x7fffffff;
}
