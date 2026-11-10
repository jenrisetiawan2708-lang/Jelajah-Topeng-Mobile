import 'package:flutter/material.dart';
import 'features/splash/splash_screen.dart';

class JelajahTopengApp extends StatelessWidget {
  const JelajahTopengApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jelajah Topeng',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}