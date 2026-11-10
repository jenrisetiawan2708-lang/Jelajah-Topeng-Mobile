import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/asset_icon.dart';
import '../../shared/widgets/gradient_background.dart';
import '../../shared/widgets/waving_panji.dart';
import 'game_header.dart';
import 'game_batik_screen.dart';
import 'game_fill_screen.dart';
import 'game_match_screen.dart';
import 'game_order_screen.dart';
import 'game_progress.dart';
import 'game_quiz_screen.dart';

class GameMapScreen extends StatefulWidget {
  const GameMapScreen({super.key});

  @override
  State<GameMapScreen> createState() => _GameMapScreenState();
}

class _GameMapScreenState extends State<GameMapScreen> {
  bool _started = false;
  int? _hintLevel; // indeks level terkunci yang petunjuknya sedang tampil
  Timer? _hintTimer;

  // Posisi tengah 5 level (ukuran desain Figma 990 x 2150), dari level 1 ke 5
  static const _levels = [
    (494.0, 1841.0),
    (265.0, 1370.0),
    (769.0, 1052.0),
    (244.0, 777.0),
    (729.0, 526.0),
  ];

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  void _showHint(int i) {
    _hintTimer?.cancel();
    setState(() => _hintLevel = i);
    _hintTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _hintLevel = null);
    });
  }

  void _openLevel(int level) {
    final Widget? page = switch (level) {
      0 => const GameQuizScreen(),
      1 => const GameOrderScreen(),
      2 => const GameMatchScreen(),
      3 => const GameFillScreen(),
      4 => const GameBatikScreen(),
      _ => null,
    };
    if (page == null) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Widget _disc(
    double s, {
    required double cx,
    required double cy,
    required Color face,
    required Color edge,
    Widget? child,
    VoidCallback? onTap,
  }) {
    final d = 300 * s;
    final lip = 22 * s;
    return Positioned(
      left: cx * s - d / 2,
      top: cy * s - d / 2,
      width: d,
      height: d + lip,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(
              top: lip,
              left: 0,
              right: 0,
              height: d,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: edge,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: d,
              child: DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle, color: face),
                child: Center(child: child),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lingkaran level: terkunci / aktif / selesai
  Widget _levelDisc(double s, int i, int done) {
    final (cx, cy) = _levels[i];

    if (i > done) {
      return _disc(
        s,
        cx: cx,
        cy: cy,
        face: const Color(0xFFBDBDBD),
        edge: const Color(0xFF909090),
        onTap: () => _showHint(i),
        child: AssetIcon(
          path: 'assets/images/ic_lock.png',
          fallback: Icons.lock,
          size: 120 * s,
          color: const Color(0xFF7C7777),
        ),
      );
    }

    final isStart = i == 0 && done == 0 && !_started;
    Widget? label;
    if (isStart) {
      label = _outlined('Start', 100 * s, 12 * s);
    } else if (i < done) {
      label = _outlined('Level ${i + 1}\nComplate', 54 * s, 8 * s);
    }

    return _disc(
      s,
      cx: cx,
      cy: cy,
      face: AppColors.edge,
      edge: AppColors.darkGreen,
      onTap: isStart ? () => setState(() => _started = true) : null,
      child: label,
    );
  }

  // Label "Level N" di bawah lingkaran yang terkunci (V2)
  Widget _levelLabel(double s, int i) {
    final (cx, cy) = _levels[i];
    final w = 300 * s;
    return Positioned(
      left: cx * s - w / 2,
      top: cy * s + (150 + 22 + 12) * s,
      width: w,
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: math.max(8.0, 24 * s),
              vertical: math.max(2.0, 6 * s),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary, width: 1),
            ),
            child: Text(
              'Level ${i + 1}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: math.max(11.0, 38 * s),
                fontWeight: FontWeight.w800,
                color: AppColors.darkGreen,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Gelembung petunjuk saat level terkunci diketuk (V2)
  Widget _hintBubble(double s, int i, int done) {
    final (cx, cy) = _levels[i];
    final w = 560 * s;
    final left = (cx * s - w / 2).clamp(8.0, 990 * s - w - 8.0).toDouble();
    return Positioned(
      left: left,
      top: cy * s - 285 * s,
      width: w,
      child: IgnorePointer(
        child: Container(
          padding: EdgeInsets.all(math.max(8.0, 22 * s)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            'Selesaikan Level ${done + 1} dulu untuk membuka Level ${i + 1}',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: math.max(11.0, 34 * s),
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // Panji berdiri di level yang sedang aktif
  Widget _panji(double s, int level) {
    final (cx, cy) = _levels[level];
    return Positioned(
      left: (cx - 200) * s,
      top: (cy - 256) * s,
      width: 400 * s,
      height: 400 * s,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openLevel(level),
        child: ClipPath(
          clipper: _PanjiClipper(s),
          child: const WavingPanji(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        colors: const [AppColors.bgTop, Colors.white],
        stops: const [0.0, 0.42],
        child: ValueListenableBuilder<int>(
          valueListenable: GameProgress.completed,
          builder: (context, done, _) {
            return LayoutBuilder(
              builder: (context, c) {
                final s = math.min(c.maxWidth / 990, c.maxHeight / 2150);
                return Stack(
                  children: [
                    // Rumput + pohon di bawah
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Image.asset(
                        'assets/images/map_ground.png',
                        fit: BoxFit.fitWidth,
                        errorBuilder: (_, _, _) => Container(
                          height: 330 * s,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8BC34A),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.elliptical(c.maxWidth, 120 * s),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Peta level
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: 990 * s,
                        height: 2150 * s,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CustomPaint(
                              size: Size(990 * s, 2150 * s),
                              painter: _DashPainter(s),
                            ),
                            for (var i = 0; i < _levels.length; i++) ...[
                              _levelDisc(s, i, done),
                              if (i > done) _levelLabel(s, i),
                            ],
                            if (done < _levels.length && (done > 0 || _started))
                              _panji(s, done),
                            if (_hintLevel != null && _hintLevel! > done)
                              _hintBubble(s, _hintLevel!, done),
                          ],
                        ),
                      ),
                    ),
                    // Header
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: GameHeader(
                            title: 'Jejak Sang Panji',
                            score: done,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Tulisan isi putih + garis tepi hijau
  Widget _outlined(String text, double size, double stroke) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: size,
            fontWeight: FontWeight.w900,
            height: 1.05,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = stroke
              ..color = AppColors.primary,
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: size,
            fontWeight: FontWeight.w900,
            height: 1.05,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// Menggambar garis putus-putus hijau antar level
class _DashPainter extends CustomPainter {
  _DashPainter(this.s);
  final double s;

  static const _curves = [
    [650.0, 1775.0, 940.0, 1640.0, 800.0, 1290.0, 430.0, 1380.0],
    [265.0, 1205.0, 280.0, 1040.0, 470.0, 1080.0, 625.0, 1130.0],
    [712.0, 908.0, 640.0, 860.0, 480.0, 895.0, 370.0, 882.0],
    [310.0, 632.0, 400.0, 540.0, 470.0, 555.0, 562.0, 528.0],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7 * s
      ..strokeCap = StrokeCap.round;

    for (final c in _curves) {
      final path = Path()
        ..moveTo(c[0] * s, c[1] * s)
        ..cubicTo(c[2] * s, c[3] * s, c[4] * s, c[5] * s, c[6] * s, c[7] * s);
      for (final m in path.computeMetrics()) {
        for (double d = 0; d < m.length; d += 34 * s) {
          canvas.drawPath(
            m.extractPath(d, math.min(d + 18 * s, m.length)),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.s != s;
}

// Bagian atas bebas (kepala & tangan boleh keluar lingkaran),
// bagian bawah dipotong mengikuti bentuk lingkaran level.
class _PanjiClipper extends CustomClipper<Path> {
  _PanjiClipper(this.s);
  final double s;

  @override
  Path getClip(Size size) {
    final circle = Rect.fromCircle(
      center: Offset(size.width / 2, 256 * s),
      radius: 150 * s,
    );
    return Path.combine(
      PathOperation.union,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, 256 * s)),
      Path()..addOval(circle),
    );
  }

  @override
  bool shouldReclip(covariant _PanjiClipper old) => old.s != s;
}