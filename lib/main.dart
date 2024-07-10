import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Presentation/Onboarding_Screen/OnboardingScreen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UiTM Go',
      home: AnimatedSplashScreen(
        splash: 'assets/logo/logo.png',
        nextScreen: const OnboardingScreen(),
        splashTransition: SplashTransition.slideTransition,
      ),
    );
  }
}
