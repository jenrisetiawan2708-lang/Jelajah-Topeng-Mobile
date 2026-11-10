import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/asset_image_box.dart';
import '../../shared/widgets/dark_button.dart';
import '../../shared/widgets/gradient_background.dart';
import 'game_final_clue_screen.dart';
import 'game_header.dart';
import 'game_progress.dart';

class GameClueScreen extends StatefulWidget {
  const GameClueScreen({
    super.key,
    required this.level,
    required this.title,
    required this.score,
    required this.text,
    required this.imagePath,
    this.glowSize = 340,
    this.goToFinal = false,
  });

  final int level;
  final String title;
  final int score;
  final String text;
  final String imagePath;
  final double glowSize; // diameter lingkaran cahaya di belakang gambar
  final bool goToFinal; // true = Next membuka clue final (khusus level 5)

  @override
  State<GameClueScreen> createState() => _GameClueScreenState();
}

class _GameClueScreenState extends State<GameClueScreen>
    with SingleTickerProviderStateMixin {
  // Gambar bergerak terus sampai halaman ditutup
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  void _next() {
    GameProgress.completeLevel(widget.level);
    if (widget.goToFinal) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GameFinalClueScreen()),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const boxW = 340.0;
    const boxH = 270.0;
    final glow = widget.glowSize;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              GameHeader(title: widget.title, score: widget.score),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: boxW,
                        height: boxH,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            // Lingkaran cahaya di belakang gambar
                            Positioned(
                              left: (boxW - glow) / 2,
                              top: boxH / 2 - glow / 2,
                              width: glow,
                              height: glow,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
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
                            // Gambar clue (gerak naik-turun + miring sedikit)
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
                              child: SizedBox(
                                width: 300,
                                height: 260,
                                child: AssetImageBox(
                                  path: widget.imagePath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          widget.text,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DarkButton(
                        text: 'Next',
                        width: 100,
                        height: 40,
                        fontSize: 16,
                        radius: 20,
                        onPressed: _next,
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