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
    if (!_initialized) {
      try {
        // Initialize timezones
        tz.initializeTimeZones();
        final String timeZoneName =
            'Asia/Kolkata'; // You might want to get this dynamically
        tz.setLocalLocation(tz.getLocation(timeZoneName));

        // Initialize notification settings
        const AndroidInitializationSettings androidSettings =
            AndroidInitializationSettings('@drawable/ic_notification');

        const InitializationSettings initSettings =
            InitializationSettings(android: androidSettings);

        // Initialize plugin
        final bool? success = await _notification.initialize(
          initSettings,
          onDidReceiveNotificationResponse: (details) {
            // Handle notification tap
          },
        );

        if (success ?? false) {
          _initialized = true;
        } else {
          throw Exception('Notification initialization failed');
        }
      } catch (e) {
        print('Error initializing notifications: $e');
        rethrow;
      }
    }
  }

  static Future<int> scheduleNotification(
    String title,
    String body,
    DateTime scheduledDateTime,
  ) async {
    try {
      // Ensure initialization
      if (!_initialized) {
        await init();
      }

      // Create notification details
      final androidDetails = const AndroidNotificationDetails(
        'important_notification',
        'Task Reminders',
        channelDescription: 'Notifications for scheduled tasks',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        styleInformation: DefaultStyleInformation(true, true),
        category: AndroidNotificationCategory.reminder,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      // Generate notification ID
      final int id = _notificationId++;

      // Convert to TZDateTime
      final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
        scheduledDateTime,
        tz.local,
      );

      // Schedule the notification
      await _notification.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      return id;
    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _notification.cancelAll();
  }

  static Future<void> cancelNotification(int id) async {
    try {
      final List<PendingNotificationRequest> pendingNotifications =
          await _notification.pendingNotificationRequests();

      if (pendingNotifications.any((notification) => notification.id == id)) {
        await _notification.cancel(id);
      }
    } catch (e) {
      print('Error canceling notification: $e');
    }
  }
}
