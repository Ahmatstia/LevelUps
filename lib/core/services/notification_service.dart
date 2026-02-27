import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:hive/hive.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _morningId = 1001;
  static const int _eveningId = 1002;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Request permissions on Android 13+
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Schedule morning briefing (07:00 setiap hari)
  Future<void> scheduleMorningBriefing({int taskCount = 0}) async {
    final settings = Hive.box('settings');
    final enabled = settings.get('notif_morning', defaultValue: true) as bool;
    if (!enabled) return;

    await _plugin.cancel(_morningId);

    try {
      await _plugin.zonedSchedule(
        _morningId,
        '⚔️ Misi Hari Ini Menunggu!',
        taskCount > 0
            ? 'Kamu punya $taskCount misi untuk diselesaikan. Siap bertarung?'
            : 'Mulai hari dengan produktif! Cek misi harianmu.',
        _nextInstanceOfTime(7, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'morning_channel',
            'Morning Briefing',
            channelDescription: 'Daily morning task briefing',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Fallback ke inexact jika exact alarm tidak diizinkan (Android 12+)
      await _plugin.zonedSchedule(
        _morningId,
        '⚔️ Misi Hari Ini Menunggu!',
        taskCount > 0
            ? 'Kamu punya $taskCount misi untuk diselesaikan. Siap bertarung?'
            : 'Mulai hari dengan produktif! Cek misi harianmu.',
        _nextInstanceOfTime(7, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'morning_channel',
            'Morning Briefing',
            channelDescription: 'Daily morning task briefing',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// Schedule evening recap (21:00 setiap hari)
  Future<void> scheduleEveningRecap() async {
    final settings = Hive.box('settings');
    final enabled = settings.get('notif_evening', defaultValue: true) as bool;
    if (!enabled) return;

    await _plugin.cancel(_eveningId);

    try {
      await _plugin.zonedSchedule(
        _eveningId,
        '🏆 Recap Harianmu Sudah Siap!',
        'Lihat pencapaianmu hari ini. Berapa XP yang kamu raih?',
        _nextInstanceOfTime(21, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'evening_channel',
            'Evening Recap',
            channelDescription: 'Daily evening progress recap',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Fallback ke inexact jika exact alarm tidak diizinkan (Android 12+)
      await _plugin.zonedSchedule(
        _eveningId,
        '🏆 Recap Harianmu Sudah Siap!',
        'Lihat pencapaianmu hari ini. Berapa XP yang kamu raih?',
        _nextInstanceOfTime(21, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'evening_channel',
            'Evening Recap',
            channelDescription: 'Daily evening progress recap',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// Notif langsung untuk task yang overdue
  Future<void> showOverdueNotification(String taskTitle) async {
    final settings = Hive.box('settings');
    final enabled = settings.get('notif_overdue', defaultValue: true) as bool;
    if (!enabled) return;

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '⚠️ Misi Terlambat!',
      '"$taskTitle" sudah melewati batas waktu!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'overdue_channel',
          'Overdue Tasks',
          channelDescription: 'Alerts for overdue tasks',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelAll() async => _plugin.cancelAll();
  Future<void> cancelMorning() async => _plugin.cancel(_morningId);
  Future<void> cancelEvening() async => _plugin.cancel(_eveningId);
}
