import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game_data.dart';
import 'game_widgets.dart';

/// Layar kuis audio. Mengembalikan `true` lewat Navigator.pop saat jawaban benar.
class GameQuizScreen extends StatefulWidget {
  const GameQuizScreen({
    super.key,
    required this.challenge,
    required this.gems,
  });

  final GameChallenge challenge;

  /// Jumlah permata sebelum tantangan ini.
  final int gems;

  @override
  State<GameQuizScreen> createState() => _GameQuizScreenState();
}

class _GameQuizScreenState extends State<GameQuizScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;

  int? _selected;
  bool _wrong = false;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _pos = p);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _dur = d);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    try {
      if (_playing) {
        await _player.pause();
        setState(() => _playing = false);
      } else {
        await _player.play(AssetSource(widget.challenge.audioAsset));
        setState(() => _playing = true);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio belum bisa diputar.')),
      );
    }
  }

  void _check() {
    if (_selected == null) return;
    if (_selected == widget.challenge.correctIndex) {
      _player.pause();
      setState(() {
        _solved = true;
        _playing = false;
      });
    } else {
      setState(() => _wrong = true);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Column(
            children: [
              GameHeader(title: c.title, gems: widget.gems + (_solved ? 1 : 0)),
              Expanded(child: _solved ? _buildClue(c) : _buildQuestion(c)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(GameChallenge c) {
    final maxMs = _dur.inMilliseconds == 0 ? 1 : _dur.inMilliseconds;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            children: [
              // Pemutar audio
              GameDarkPanel(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _toggleAudio,
                      child: Container(
                        width: 66,
                        height: 66,
                        decoration: const BoxDecoration(
                          color: GameColors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white,
                        thumbColor: GameColors.green,
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                      ),
                      child: Slider(
                        value: _pos.inMilliseconds.clamp(0, maxMs).toDouble(),
                        max: maxMs.toDouble(),
                        onChanged: _dur == Duration.zero
                            ? null
                            : (v) => _player.seek(
                                Duration(milliseconds: v.toInt()),
                              ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _fmt(_pos),
                          style: gameText(14, color: Colors.white),
                        ),
                        Text(
                          _fmt(_dur),
                          style: gameText(14, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Pertanyaan
              GameDarkPanel(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    c.question,
                    style: gameText(
                      18,
                      weight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              for (var i = 0; i < c.options.length; i++) ...[
                _OptionTile(
                  text: c.options[i],
                  selected: _selected == i,
                  wrong: _wrong && _selected == i,
                  onTap: () => setState(() {
                    _selected = i;
                    _wrong = false;
                  }),
                ),
                const SizedBox(height: 16),
              ],
              if (_wrong) _HintBox(hint: c.hint),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
          child: GameButton(
            text: 'Cek Jawaban',
            onPressed: _selected == null ? null : _check,
          ),
        ),
      ],
    );
  }

  Widget _buildClue(GameChallenge c) {
    return ClueReveal(
      image: c.clueImage,
      text: c.clue,
      clueNumber: widget.gems + 1,
      onNext: () => Navigator.of(context).pop(true),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.selected,
    required this.wrong,
    required this.onTap,
  });
  final String text;
  final bool selected;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = wrong ? GameColors.wrong : GameColors.greenLine;
    final width = (wrong || selected) ? 2.6 : 1.4;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          color: wrong
              ? const Color(0xFFFFF4F3)
              : selected
              ? const Color(0xFFF1FAE6)
              : Colors.white,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: color, width: width),
          boxShadow: [
            // bibir tipis di bawah (efek timbul)
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              offset: const Offset(0, 4),
            ),
            // bayangan lembut
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Text(text, style: gameText(17)),
      ),
    );
  }
}

class _HintBox extends StatelessWidget {
  const _HintBox({required this.hint});
  final String hint;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: GameColors.wrongBar.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          color: GameColors.wrongBg,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 10, color: GameColors.wrongBar),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Belum tepat. Coba lagi!',
                          style: gameText(
                            17,
                            weight: FontWeight.w800,
                            color: GameColors.wrongText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Petunjuk: $hint',
                          style: gameText(13, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tampilan "clue terbuka": topeng muncul membal, sinar berputar,
/// konfeti jatuh, lalu teks dan tombol Next menyusul.
class ClueReveal extends StatefulWidget {
  const ClueReveal({
    required this.image,
    required this.text,
    required this.clueNumber,
    required this.onNext,
  });
  final String image;
  final String text;
  final int clueNumber;
  final VoidCallback onNext;

  @override
  State<ClueReveal> createState() => _ClueRevealState();
}

class _ClueRevealState extends State<ClueReveal> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();
  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..forward();
  late final List<_Piece> _pieces = _makePieces();

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    _confetti.dispose();
    super.dispose();
  }

  static List<_Piece> _makePieces() {
    final r = math.Random(11);
    const colors = [
      Color(0xFFFFC94D),
      Color(0xFF66A03A),
      Color(0xFFFF7A59),
      Color(0xFF4FC3F7),
      Color(0xFFE85D9B),
      Colors.white,
    ];
    return List.generate(
      48,
      (_) => _Piece(
        x: r.nextDouble(),
        delay: r.nextDouble() * 0.35,
        size: 6 + r.nextDouble() * 7,
        phase: r.nextDouble() * 6.28,
        spin: 2 + r.nextDouble() * 5,
        color: colors[r.nextInt(colors.length)],
      ),
    );
  }

  Animation<double> _iv(double a, double b, [Curve curve = Curves.easeOut]) =>
      CurvedAnimation(
        parent: _intro,
        curve: Interval(a, b, curve: curve),
      );

  @override
  Widget build(BuildContext context) {
    final pop = _iv(0.0, 0.55, Curves.elasticOut);
    final popFade = _iv(0.0, 0.2);
    final badge = _iv(0.15, 0.45, Curves.easeOutBack);
    final text = _iv(0.5, 0.8);
    final button = _iv(0.75, 1.0, Curves.easeOutBack);
    final buttonFade = _iv(0.75, 1.0);

    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: badge,
                  child: FadeTransition(
                    opacity: _iv(0.15, 0.4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD86B), Color(0xFFF2B63C)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF2B63C)
                                .withValues(alpha: 0.5),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_open_rounded,
                            size: 18,
                            color: GameColors.forestDark,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Clue ${widget.clueNumber} terbuka!',
                            style: gameText(
                              14,
                              weight: FontWeight.w800,
                              color: GameColors.forestDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 340,
                  height: 340,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      FadeTransition(
                        opacity: _iv(0.05, 0.4),
                        child: AnimatedBuilder(
                          animation: _loop,
                          builder: (_, _) => Transform.rotate(
                            angle: _loop.value * 2 * math.pi,
                            child: const CustomPaint(
                              size: Size(340, 340),
                              painter: _RaysPainter(),
                            ),
                          ),
                        ),
                      ),
                      FadeTransition(
                        opacity: popFade,
                        child: Container(
                          width: 290,
                          height: 290,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Color(0xFFFFDFA3), Color(0x00FFF5E0)],
                            ),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _loop,
                        child: ScaleTransition(
                          scale: pop,
                          child: FadeTransition(
                            opacity: popFade,
                            child: _ClueImage(path: widget.image),
                          ),
                        ),
                        builder: (_, child) => Transform.translate(
                          offset: Offset(
                            0,
                            math.sin(_loop.value * 2 * math.pi * 4) * 6,
                          ),
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                FadeTransition(
                  opacity: text,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.25),
                      end: Offset.zero,
                    ).animate(text),
                    child: Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: gameText(17, weight: FontWeight.w800, height: 1.3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: buttonFade,
                  child: ScaleTransition(
                    scale: button,
                    child: GameButton(
                      text: 'Next',
                      width: 150,
                      onPressed: widget.onNext,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Konfeti di atas semuanya, tidak menghalangi sentuhan.
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _confetti,
              builder: (_, _) => CustomPaint(
                painter: _ConfettiPainter(_pieces, _confetti.value),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.size,
    required this.phase,
    required this.spin,
    required this.color,
  });
  final double x;
  final double delay;
  final double size;
  final double phase;
  final double spin;
  final Color color;
}

class _RaysPainter extends CustomPainter {
  const _RaysPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final paint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x99FFD27A), Color(0x00FFD27A)],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    const n = 12;
    for (var i = 0; i < n; i++) {
      final a0 = i * 2 * math.pi / n;
      final a1 = a0 + math.pi / n;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + math.cos(a0) * r, c.dy + math.sin(a0) * r)
        ..lineTo(c.dx + math.cos(a1) * r, c.dy + math.sin(a1) * r)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.v);
  final List<_Piece> pieces;
  final double v;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final t = ((v - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0 || t >= 1) continue;
      final y = -20 + t * (size.height + 40);
      final x = p.x * size.width + math.sin(t * math.pi * 3 + p.phase) * 18;
      final opacity = t > 0.85 ? (1 - t) / 0.15 : 1.0;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * p.spin * math.pi * 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.5,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = p.color.withValues(alpha: opacity),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.v != v;
}

/// Memuat gambar reward. Kalau path persis tidak ada, dicari aset lain yang
/// namanya mengandung "clue" supaya salah nama/huruf besar tidak jadi masalah.
class _ClueImage extends StatefulWidget {
  const _ClueImage({required this.path});
  final String path;

  @override
  State<_ClueImage> createState() => _ClueImageState();
}

class _ClueImageState extends State<_ClueImage> {
  late final Future<String?> _future = _resolve(widget.path);

  static Future<String?> _resolve(String wanted) async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final all = manifest.listAssets();
      if (all.contains(wanted)) return wanted;
      final lowerWanted = wanted.toLowerCase();
      for (final a in all) {
        if (a.toLowerCase() == lowerWanted) return a;
      }
      for (final a in all) {
        final l = a.toLowerCase();
        if ((l.endsWith('.png') || l.endsWith('.webp')) && l.contains('clue')) {
          return a;
        }
      }
      debugPrint(
        'Aset clue tidak ditemukan. Gambar terdaftar:\n'
        '${all.where((a) => a.startsWith('assets/images')).join('\n')}',
      );
    } catch (e) {
      debugPrint('Gagal membaca daftar aset: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _future,
      builder: (_, snap) {
        final p = snap.data;
        if (p == null) {
          return SizedBox(
            width: 240,
            height: 240,
            child: snap.connectionState != ConnectionState.done
                ? null
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.theater_comedy_rounded,
                        size: 120,
                        color: GameColors.forestDark,
                      ),
                      if (kDebugMode)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'maks_clue.png tidak ditemukan di aset',
                            textAlign: TextAlign.center,
                            style: gameText(11, color: Colors.red),
                          ),
                        ),
                    ],
                  ),
          );
        }
        return Image.asset(
          p,
          width: 240,
          fit: BoxFit.contain,
          errorBuilder: (_, error, _) {
            debugPrint('Gagal memuat $p: $error');
            return const Icon(
              Icons.theater_comedy_rounded,
              size: 140,
              color: GameColors.forestDark,
            );
          },
        );
      },
    );
  }
}
