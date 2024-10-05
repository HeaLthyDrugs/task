import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
// Add this import
import 'package:flutter/foundation.dart';

class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
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

  static Future<void> scheduleNotification(
    String title,
    String body,
    int userDayInput,
  ) async {
    await init(); // Ensure initialization before scheduling

    var androidDetails = const AndroidNotificationDetails(
      "important_notification",
      "My channel",
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);

    // Check if the app has permission for exact alarms
    final bool? result = await _notification
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    if (result ?? false) {
      await _notification.zonedSchedule(
        0,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(Duration(seconds: userDayInput)),
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else {
      if (kDebugMode) {
        print('Exact alarms permission not granted');
      }
      // Fallback to inexact scheduling
      await _notification.zonedSchedule(
        0,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(Duration(seconds: userDayInput)),
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _notification.cancelAll();
  }
}
