import 'dart:async';

import 'package:flutter/material.dart';

import 'game_data.dart';
import 'game_order_screen.dart';
import 'game_quiz_screen.dart';
import 'game_widgets.dart';

/// Peta level "Jejak Sang Panji". Dibuka sebagai layar penuh (tanpa navbar).
class GameMapScreen extends StatefulWidget {
  const GameMapScreen({super.key});

  @override
  State<GameMapScreen> createState() => _GameMapScreenState();
}

class _GameMapScreenState extends State<GameMapScreen> {
  // Posisi pusat lingkaran (0..1), diambil dari desain.
  // Urutan: level 1 (Start, paling bawah) sampai level 5 (paling atas).
  static const _slots = <Offset>[
    Offset(0.499, 0.861),
    Offset(0.269, 0.640),
    Offset(0.776, 0.493),
    Offset(0.247, 0.365),
    Offset(0.737, 0.249),
  ];

  /// Lokasi gambar. Ganti kalau nama atau foldernya berbeda.
  static const _groundAsset = 'assets/images/map_ground.png';
  static const _panjiAsset = 'assets/images/ic_lock.png';

  int _completed = 0;
  bool _started = false;
  String? _message;
  int _messageToken = 0;

  void _showMessage(String text) {
    final token = ++_messageToken;
    setState(() => _message = text);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && token == _messageToken) setState(() => _message = null);
    });
  }

  Future<void> _openChallenge(int index) async {
    setState(() => _started = true);
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => index == 1
            ? GameOrderScreen(gems: _completed)
            : GameQuizScreen(
                challenge: gameChallenges[index],
                gems: _completed,
              ),
      ),
    );
    if (ok == true && mounted && _completed == index) {
      setState(() => _completed++);
    }
  }

  void _onNodeTap(int i) {
    if (i == _completed) {
      _openChallenge(i);
    } else if (i > _completed) {
      _showMessage(
        'Selesaikan Level ${_completed + 1} agar dapat membuka level ${i + 1}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GameBackground(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final h = c.maxHeight;
            final d = (w * 0.32).clamp(0.0, h * 0.147).toDouble();
            final pts = [for (final s in _slots) Offset(s.dx * w, s.dy * h)];

            return Stack(
              fit: StackFit.expand,
              children: [
                // Rumput dari foto, menempel di bawah.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Image.asset(
                    _groundAsset,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.bottomCenter,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),

                // Jalur putus-putus.
                Positioned.fill(
                  child: CustomPaint(painter: _DashedPathPainter(pts)),
                ),

                // Lingkaran level.
                for (var i = 0; i < _slots.length; i++)
                  Positioned(
                    left: pts[i].dx - d / 2,
                    top: pts[i].dy - d / 2,
                    child: _LevelNode(
                      diameter: d,
                      state: i < _completed
                          ? _NodeState.done
                          : i == _completed
                          ? _NodeState.current
                          : _NodeState.locked,
                      showStart: i == 0 && !_started && _completed == 0,
                      onTap: () => _onNodeTap(i),
                    ),
                  ),

                // Karakter Panji berdiri di level aktif.
                if (_completed < _slots.length && (_started || _completed > 0))
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeInOutCubic,
                    left: pts[_completed].dx - d * 0.55,
                    top: pts[_completed].dy - d * 1.0,
                    width: d * 1.1,
                    height: d * 1.3,
                    child: IgnorePointer(
                      child: _Bobbing(
                        child: Image.asset(
                          _panjiAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.person_rounded,
                            size: d * 0.8,
                            color: GameColors.forestDark,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Redupkan layar + pesan saat level terkunci ditekan.
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: _message == null,
                    child: GestureDetector(
                      onTap: () => setState(() => _message = null),
                      child: AnimatedOpacity(
                        opacity: _message == null ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.only(top: h * 0.19),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                            child: Text(
                              _message ?? '',
                              textAlign: TextAlign.center,
                              style: gameText(
                                13,
                                weight: FontWeight.w700,
                                color: GameColors.forestDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Header selalu menempel di atas.
                Align(
                  alignment: Alignment.topCenter,
                  child: SafeArea(
                    bottom: false,
                    child: GameHeader(
                      title: 'Jejak Sang Panji',
                      gems: _completed,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

enum _NodeState { locked, current, done }

class _LevelNode extends StatelessWidget {
  const _LevelNode({
    required this.diameter,
    required this.state,
    required this.showStart,
    required this.onTap,
  });

  final double diameter;
  final _NodeState state;
  final bool showStart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = state == _NodeState.locked;
    final depth = diameter * 0.06;
    final top = locked ? GameColors.lockTop : GameColors.green;
    final side = locked ? GameColors.lockSide : GameColors.forestDark;

    Widget face;
    if (locked) {
      face = Icon(
        Icons.lock_rounded,
        size: diameter * 0.34,
        color: GameColors.lockIcon,
      );
    } else if (state == _NodeState.done) {
      face = Icon(
        Icons.check_rounded,
        size: diameter * 0.5,
        color: Colors.white,
      );
    } else if (showStart) {
      face = _StartLabel(size: diameter * 0.24);
    } else {
      face = const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: diameter,
        height: diameter + depth,
        child: Stack(
          children: [
            Positioned(
              top: depth,
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: side,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(shape: BoxShape.circle, color: top),
              alignment: Alignment.center,
              child: face,
            ),
          ],
        ),
      ),
    );
  }
}

/// Teks "Start" putih dengan garis tepi hijau.
class _StartLabel extends StatelessWidget {
  const _StartLabel({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    final base = gameText(size, weight: FontWeight.w900);
    return Stack(
      children: [
        Text(
          'Start',
          style: base.copyWith(
            color: null,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = size * 0.16
              ..strokeJoin = StrokeJoin.round
              ..color = const Color(0xFF3FA84A),
          ),
        ),
        Text('Start', style: base.copyWith(color: Colors.white)),
      ],
    );
  }
}

/// Jalur lengkung putus-putus: level 1 -> 2 -> 3 -> 4 -> 5.
class _DashedPathPainter extends CustomPainter {
  _DashedPathPainter(this.p);
  final List<Offset> p;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()..moveTo(p[0].dx, p[0].dy);
    path.cubicTo(
      w * 0.98,
      p[0].dy - h * 0.03,
      w * 0.98,
      p[1].dy - h * 0.06,
      p[1].dx,
      p[1].dy,
    );
    path.cubicTo(
      w * 0.22,
      p[1].dy - h * 0.12,
      w * 0.50,
      p[2].dy,
      p[2].dx,
      p[2].dy,
    );
    path.cubicTo(
      w * 0.62,
      p[2].dy - h * 0.09,
      w * 0.40,
      p[3].dy + h * 0.03,
      p[3].dx,
      p[3].dy,
    );
    path.cubicTo(
      w * 0.25,
      p[3].dy - h * 0.07,
      w * 0.50,
      p[4].dy - h * 0.01,
      p[4].dx,
      p[4].dy,
    );

    final paint = Paint()
      ..color = GameColors.greenLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    const dash = 6.0;
    const gap = 9.0;
    for (final m in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < m.length) {
        final end = (dist + dash).clamp(0.0, m.length).toDouble();
        canvas.drawPath(m.extractPath(dist, end), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPathPainter old) => old.p != p;
}

/// Karakter naik-turun pelan dengan sedikit melar, supaya terlihat hidup.
class _Bobbing extends StatefulWidget {
  const _Bobbing({required this.child});
  final Widget child;

  @override
  State<_Bobbing> createState() => _BobbingState();
}

class _BobbingState extends State<_Bobbing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -9 * _t.value),
        child: Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.diagonal3Values(
            1 - 0.015 * _t.value,
            1 + 0.03 * _t.value,
            1,
          ),
          child: child,
        ),
      ),
    );
  }
}
