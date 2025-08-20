/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationProvider extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  static const String _channelId = 'main_channel';
  static const String _channelName = 'Workout Reminders';
  static const String _channelDescription = 'Reminders to stay active';

  NotificationProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings();
    final settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(settings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final status = await Permission.notification.status;
    final prefs = await SharedPreferences.getInstance();
    final savedPreference = prefs.getBool('notifications_enabled') ?? false;

    _isEnabled = status.isGranted && savedPreference;

    if (!_isEnabled) {
      await _plugin.cancelAll();
    }

    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    if (enabled) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        _isEnabled = true;
        await prefs.setBool('notifications_enabled', true);
        await scheduleWeeklyNotifications(); // ⬅ Schedule when enabled
      } else {
        _isEnabled = false;
        await prefs.setBool('notifications_enabled', false);
        await _plugin.cancelAll();
      }
    } else {
      _isEnabled = false;
      await prefs.setBool('notifications_enabled', false);
      await _plugin.cancelAll();
    }

    notifyListeners();
  }

  Future<void> scheduleWeeklyNotifications() async {
    if (!_isEnabled) return;

    final now = tz.TZDateTime.now(tz.local);
    final time =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 12); // 12:00 PM
    final List<int> weekdays = [DateTime.monday, DateTime.thursday];
    int id = 100;

    for (int weekday in weekdays) {
      tz.TZDateTime scheduledDate = _nextInstanceOfWeekday(time, weekday);

      await _plugin.zonedSchedule(
        id++,
        '🏋️ Time to Work Out!',
        'Don’t forget your workout today! 💪',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }

    print('✅ Scheduled workout reminders for Monday and Thursday at 12:00 PM');
  }

  tz.TZDateTime _nextInstanceOfWeekday(tz.TZDateTime time, int weekday) {
    while (time.weekday != weekday) {
      time = time.add(const Duration(days: 1));
    }
    return time;
  }

  Future<void> triggerTestNotification() async {
    if (!_isEnabled) {
      print('Notification is disabled.');
      return;
    }

    await _plugin.show(
      999,
      '🚀 Workout Reminder',
      'This is your test notification! 💪',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'test',
    );
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    _isEnabled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', false);
    notifyListeners();
  }
}
*/
