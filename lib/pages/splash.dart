import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:todo_app/pages/home_page.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Lottie.asset(
        'assets/animations/ghost.json',
        width: 200,
        height: 200,
        fit: BoxFit.contain,
      ),
      nextScreen: const HomePage(),
      duration: 3000,
      backgroundColor: Colors.white,
    );
  }
}
