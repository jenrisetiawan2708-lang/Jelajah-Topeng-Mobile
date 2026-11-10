import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../home/home_screen.dart';

/// Sambutan awal (V2)
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  // rasio gambar welcome_hero.jpg (990 x 1100)
  static const double _heroRatio = 1100 / 990;

  void _toHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final heroH = math.min(size.width * _heroRatio, size.height * 0.56);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.forest,
        body: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: heroH,
              child: Image.asset(
                'assets/images/welcome_hero.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Column(
                    children: [
                      const Spacer(),
                      Text(
                        'Petualangan Budaya\nDimulai dari Sini!',
                        textAlign: TextAlign.center,
                        style: AppText.style(
                          28,
                          weight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Kenali Topeng Malang dan Kampung Budaya Polowijen lewat cerita, peta, dan permainan.',
                        textAlign: TextAlign.center,
                        style: AppText.style(
                          14,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.45,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => _toHome(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            'Mulai Petualangan',
                            style: AppText.style(
                              16,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () => _toHome(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: AppColors.accent,
                              width: 1.5,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            'Saya sudah punya akun',
                            style: AppText.style(
                              16,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}