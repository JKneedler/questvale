import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  int _notificationId(String reminderId) => reminderId.hashCode & 0x7fffffff;
}
