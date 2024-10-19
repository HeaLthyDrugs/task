import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/helper/notification_helper.dart';
import 'package:todo_app/pages/home_page.dart';
import 'package:todo_app/pages/splash.dart';
import 'package:todo_app/theme/theme.dart';
import 'package:todo_app/theme/theme_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  await NotificationHelper.init();
  await Hive.initFlutter();

  var box = await Hive.openBox('myBox');

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_notification');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    // ... iOS settings if needed
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // ... other initialization parameters
  );

  runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(), child: const MyApp()));
}

Future<void> requestPermissions() async {
  await Permission.notification.request();
  if (await Permission.scheduleExactAlarm.request().isGranted) {
    // This permission is only available on Android 12 and above
    // For lower versions, this will always return true
    print('Exact alarm permission granted');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: context.watch<ThemeProvider>().getTheme(),
      home: const Splash(),
    );
  }
}
