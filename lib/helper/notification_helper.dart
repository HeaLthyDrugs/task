import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:todo_app/main.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static int _notificationId = 0;

  static Future<void> init() async {
    await flutterLocalNotificationsPlugin
        .cancel(NotificationHelper._notificationId);
    if (!_initialized) {
      tz.initializeTimeZones();
      tz.setLocalLocation(
          tz.getLocation('Asia/Kolkata')); // Set to Indian Standard Time
      await _notification.initialize(const InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      ));
      _initialized = true;
    }
  }

  static Future<int> scheduleNotification(
    String title,
    String body,
    DateTime scheduledDateTime,
  ) async {
    try {
      await init(); // Ensure initialization before scheduling

      // Check for notification permission
      if (!(await Permission.notification.isGranted)) {
        throw Exception('Notification permission not granted');
      }

      var androidDetails = const AndroidNotificationDetails(
        "important_notification",
        "Task Reminders",
        channelDescription: "Notifications for scheduled tasks",
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        icon: 'ic_notification',
      );
      var notificationDetails = NotificationDetails(android: androidDetails);

      int id = _notificationId++;

      // Ensure the scheduled time is in the future
      tz.TZDateTime scheduledDate =
          tz.TZDateTime.from(scheduledDateTime, tz.local);
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        scheduledDate =
            tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
      }

      // Check for exact alarm permission
      if (await Permission.scheduleExactAlarm.isGranted) {
        await _notification.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } else {
        print('Exact alarms permission not granted');
        // Fallback to inexact scheduling
        await _notification.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }

      return id; // Return the notification ID
    } catch (e) {
      print('Error scheduling notification: $e');
      throw e; // Re-throw the error to be caught in saveNewTask
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _notification.cancelAll();
  }

  static cancelNotification(notificationId) {}
}
