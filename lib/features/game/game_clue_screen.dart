import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/widgets/asset_image_box.dart';
import '../../shared/widgets/dark_button.dart';
import '../../shared/widgets/gradient_background.dart';
import 'game_celebration.dart';
import 'game_clues.dart';
import 'game_final_clue_screen.dart';
import 'game_header.dart';
import 'game_progress.dart';

class GameClueScreen extends StatefulWidget {
  const GameClueScreen({
    super.key,
    required this.level,
    // Parameter di bawah ini diabaikan (isi diambil dari game_clues.dart).
    // Dibiarkan supaya layar game lama tidak error.
    this.title,
    this.score,
    this.text,
    this.imagePath,
    this.glowSize,
    this.goToFinal,
  });

  final int level;
  final String? title;
  final int? score;
  final String? text;
  final String? imagePath;
  final double? glowSize;
  final bool? goToFinal;

  @override
  State<GameClueScreen> createState() => _GameClueScreenState();
}

class _GameClueScreenState extends State<GameClueScreen>
    with TickerProviderStateMixin {
  // Gambar bergerak terus sampai halaman ditutup.
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  // Gambar muncul membal saat layar dibuka.
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  )..forward();

  GameClue get _clue =>
      kGameClues[(widget.level - 1).clamp(0, kGameClues.length - 1)];
  bool get _isFinal => widget.level >= kGameClues.length;

  @override
  void dispose() {
    _float.dispose();
    _enter.dispose();
    super.dispose();
  }

  void _next() {
    GameProgress.completeLevel(widget.level);
    if (_isFinal) {
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
    final clue = _clue;
    final glow = clue.glow;
    final rays = glow + 80;
    final pop = CurvedAnimation(parent: _enter, curve: Curves.easeOutBack);

    return Scaffold(
      body: GradientBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  GameHeader(title: 'Jejak Sang Panji', score: widget.level),
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
                                // Sinar cahaya berputar.
                                Positioned(
                                  left: (boxW - rays) / 2,
                                  top: boxH / 2 - rays / 2,
                                  width: rays,
                                  height: rays,
                                  child: IgnorePointer(
                                    child: GameRays(size: rays),
                                  ),
                                ),
                                // Lingkaran cahaya lembut.
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
                                // Gambar clue.
                                AnimatedBuilder(
                                  animation: Listenable.merge([_float, pop]),
                                  builder: (_, child) {
                                    final t = Curves.easeInOut.transform(
                                      _float.value,
                                    );
                                    return Opacity(
                                      opacity: pop.value.clamp(0.0, 1.0),
                                      child: Transform.scale(
                                        scale: 0.6 + 0.4 * pop.value,
                                        child: Transform.translate(
                                          offset: Offset(0, 5 - 10 * t),
                                          child: Transform.rotate(
                                            angle: (t - 0.5) * 0.05,
                                            child: child,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width: 300,
                                    height: 260,
                                    child: AssetImageBox(
                                      path: clue.image,
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
                              clue.text.toUpperCase(),
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
            // Konfeti di atas segalanya.
            const Positioned.fill(child: IgnorePointer(child: GameConfetti())),
          ],
        ),
      ),
    );
  }
}
