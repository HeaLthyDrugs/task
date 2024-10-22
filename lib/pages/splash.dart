import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:todo_app/pages/home_page.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:page_transition/page_transition.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Task',
                textStyle: TextStyle(
                    fontSize: 42,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat'),
                speed: Duration(milliseconds: 800),
              ),
            ],
            totalRepeatCount: 1,
          ),
        ],
      ),
      nextScreen: const HomePage(),
      duration: 5000,
      splashIconSize: 250,
      backgroundColor: Colors.white,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}
