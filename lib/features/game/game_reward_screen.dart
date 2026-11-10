import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/asset_image_box.dart';
import '../../shared/widgets/dark_button.dart';
import '../../shared/widgets/gradient_background.dart';
import 'game_congrats_screen.dart';
import 'game_header.dart';

class GameRewardScreen extends StatefulWidget {
  const GameRewardScreen({super.key});

  @override
  State<GameRewardScreen> createState() => _GameRewardScreenState();
}

class _GameRewardScreenState extends State<GameRewardScreen>
    with SingleTickerProviderStateMixin {
  // Medali bergerak terus sampai halaman ditutup
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const GameHeader(title: 'Jejak Sang Panji', score: 5),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 290,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Lingkaran cahaya besar di belakang medali
                            OverflowBox(
                              maxWidth: 410,
                              maxHeight: 410,
                              child: Container(
                                width: 410,
                                height: 410,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Color(0xFFFFEBC2),
                                      Color(0xFFF6FAE9),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _float,
                              builder: (_, child) {
                                final t =
                                    Curves.easeInOut.transform(_float.value);
                                return Transform.translate(
                                  offset: Offset(0, 5 - 10 * t),
                                  child: Transform.rotate(
                                    angle: (t - 0.5) * 0.05,
                                    child: child,
                                  ),
                                );
                              },
                              child: const SizedBox(
                                width: 280,
                                height: 280,
                                child: AssetImageBox(
                                  path: 'assets/images/reward_dewi.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'DEWI SEKARTAJI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Selamat! Kalian berhasil menemukan Sang Putri dari kisah Panji.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DarkButton(
                        text: 'Klaim Reward',
                        width: 124,
                        height: 40,
                        fontSize: 16,
                        radius: 20,
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const GameCongratsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}