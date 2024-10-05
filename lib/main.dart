import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/helper/notification_helper.dart';
import 'package:todo_app/pages/home_page.dart';
import 'package:todo_app/theme/theme.dart';
import 'package:todo_app/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationHelper.init();
  await Hive.initFlutter();

  var box = await Hive.openBox('myBox');

  runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: context.watch<ThemeProvider>().getTheme(),
      home: const HomePage(),
    );
  }
}
