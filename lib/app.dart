import 'package:flutter/material.dart';

import 'core/api/api_client.dart';
import 'features/auth/login_screen.dart';
import 'features/splash/splash_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class JelajahTopengApp extends StatefulWidget {
  const JelajahTopengApp({super.key});

  @override
  State<JelajahTopengApp> createState() => _JelajahTopengAppState();
}

class _JelajahTopengAppState extends State<JelajahTopengApp> {
  @override
  void initState() {
    super.initState();
    ApiClient.sessionExpired.addListener(_onExpired);
  }

  @override
  void dispose() {
    ApiClient.sessionExpired.removeListener(_onExpired);
    super.dispose();
  }

  void _onExpired() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Jelajah Topeng',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
