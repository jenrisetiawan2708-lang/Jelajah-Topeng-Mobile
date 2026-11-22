import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Sinar cahaya emas yang berputar pelan di belakang gambar reward.
class GameRays extends StatefulWidget {
  const GameRays({super.key, this.size = 360});
  final double size;

  @override
  State<GameRays> createState() => _GameRaysState();
}

class _GameRaysState extends State<GameRays>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(painter: _RaysPainter(_c.value)),
      ),
    );
  }
}

class _RaysPainter extends CustomPainter {
  _RaysPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final paint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x77FFD66B), Color(0x00FFD66B)],
      ).createShader(Rect.fromCircle(center: c, radius: r));

    const n = 12;
    const half = 0.11;
    for (var i = 0; i < n; i++) {
      final a = t * 2 * math.pi + i * 2 * math.pi / n;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + r * math.cos(a - half), c.dy + r * math.sin(a - half))
        ..lineTo(c.dx + r * math.cos(a + half), c.dy + r * math.sin(a + half))
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RaysPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------

/// Konfeti yang jatuh sekali saat layar muncul. Pakai di Positioned.fill.
class GameConfetti extends StatefulWidget {
  const GameConfetti({super.key});

  @override
  State<GameConfetti> createState() => _GameConfettiState();
}

class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.drift,
    required this.phase,
    required this.spin,
    required this.w,
    required this.h,
    required this.color,
    required this.round,
  });
  final double x, delay, speed, drift, phase, spin, w, h;
  final Color color;
  final bool round;
}

class _GameConfettiState extends State<GameConfetti>
    with SingleTickerProviderStateMixin {
  static const _colors = [
    Color(0xFFFFC857),
    Color(0xFF66AA5A),
    Color(0xFFE76F51),
    Color(0xFF4CC9F0),
    Color(0xFFF7A8C4),
    Color(0xFFFFE066),
  ];

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..forward();

  // Seed tetap: pola konfeti selalu sama di setiap level.
  late final List<_Piece> _pieces = () {
    final rnd = math.Random(11);
    return List.generate(52, (i) {
      return _Piece(
        x: rnd.nextDouble(),
        delay: rnd.nextDouble() * 0.35,
        speed: 0.75 + rnd.nextDouble() * 0.5,
        drift: 10 + rnd.nextDouble() * 26,
        phase: rnd.nextDouble() * 6.28,
        spin: 2 + rnd.nextDouble() * 6,
        w: 6 + rnd.nextDouble() * 6,
        h: 9 + rnd.nextDouble() * 8,
        color: _colors[i % _colors.length],
        round: i % 4 == 0,
      );
    });
  }();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(_pieces, _c.value),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);
  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final y = -30 + local * (size.height + 60) * p.speed * 0.9;
      final x = p.x * size.width + math.sin(local * 7 + p.phase) * p.drift;
      final fade = local > 0.8 ? 1 - (local - 0.8) / 0.2 : 1.0;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(local * p.spin);
      final paint = Paint()..color = p.color.withValues(alpha: fade);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.w / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.w, height: p.h),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
