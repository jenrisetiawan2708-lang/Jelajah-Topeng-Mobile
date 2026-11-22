import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../auth/auth_service.dart';
import '../game/game_progress.dart';
import '../notification/notification_screen.dart';

/// Warna halaman Progres Budaya (diambil dari Figma).
class _C {
  static const bgTop = Color(0xFFD2EEA4);
  static const bgMid = Color(0xFFFBFDF8);
  static const bgBottom = Color(0xFFE0F5C0);

  static const ink = Color(0xFF1E2B12);
  static const sub = Color(0xFF6B7F5A);

  static const tileTop = Color(0xFF223316);
  static const tileMid = Color(0xFF3A5527);
  static const tileBottom = Color(0xFF58773C);
  static const tileLip = Color(0xFF6E9A47);

  static const barLeft = Color(0xFF2F4A22);
  static const barRight = Color(0xFF58773C);
  static const barLip = Color(0xFF6E9A47);

  static const rankFill = Color(0xFF2A3E1D);
  static const rankLip = Color(0xFF58803A);

  static const green = Color(0xFF66AA5A);
  static const lime = Color(0xFFB8F08C);
  static const gold = Color(0xFFD9A441);
  static const track = Color(0xFFDDE6D3);
  static const red = Color(0xFFE0453A);
}

class _Rank {
  const _Rank(this.place, this.name, this.score);
  final int place;
  final String name;
  final int score;
}

// Data contoh. Nanti diganti dari backend (leaderboard).
const _board = [
  _Rank(1, 'Raja Esa Abdilah', 4),
  _Rank(2, 'Jenri Setiawan Sitepu', 2),
  _Rank(3, 'Ardli Miftah', 0),
];

const _totalLevels = 5;
const _notifCount = 3;

/// Progres sebagian per level (0.0 - 1.0) untuk level yang sedang dikerjakan.
/// Level yang sudah selesai otomatis penuh, level yang belum disentuh kosong.
/// Layar game mengisinya lewat LevelProgress.set(indexLevel, nilai).
class LevelProgress {
  static final ValueNotifier<Map<int, double>> byLevel =
      ValueNotifier<Map<int, double>>({});

  static void set(int level, double value) {
    final m = Map<int, double>.of(byLevel.value);
    m[level] = value.clamp(0.0, 1.0);
    byLevel.value = m;
  }
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  String get _firstName {
    final full = AuthService.current?.name.trim() ?? '';
    if (full.isEmpty) return 'Sobat';
    return full.split(RegExp(r'\s+')).first;
  }

  /// Muncul pelan dari bawah, bergantian sesuai urutannya.
  Widget _in(int i, Widget child) {
    final b = (0.04 + i * 0.09).clamp(0.0, 0.7);
    final e = (b + 0.35).clamp(0.0, 1.0);
    final a = CurvedAnimation(
      parent: _enter,
      curve: Interval(b, e, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(a),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bgTop,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_C.bgTop, _C.bgMid, _C.bgBottom],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: ValueListenableBuilder<int>(
            valueListenable: GameProgress.completed,
            builder: (context, completed, _) {
              final done = completed.clamp(0, _totalLevels);
              final certificates = done >= _totalLevels ? 1 : 0;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                children: [
                  _in(0, _buildHeader(context)),
                  const SizedBox(height: 20),
                  _in(1, _buildHero(done)),
                  const SizedBox(height: 14),
                  _in(
                    2,
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            icon: Icons.flag_rounded,
                            value: '$done',
                            label: 'Progres',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniStat(
                            icon: Icons.workspace_premium_rounded,
                            value: '$certificates',
                            label: 'Sertifikat',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  _in(3, _sectionTitle('Koleksi Game', '$done/$_totalLevels')),
                  const SizedBox(height: 12),
                  _in(4, _buildCollection(done)),
                  const SizedBox(height: 26),
                  _in(5, _sectionTitle('Leaderboard')),
                  const SizedBox(height: 12),
                  for (var i = 0; i < _board.length; i++)
                    _in(
                      6 + i,
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRankRow(_board[i]),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ header
  /// Seperti di Beranda: "Hey, Nama!" + "Selamat Datang" + lonceng notifikasi.
  Widget _buildHeader(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Row(
      children: [
        if (canPop) ...[
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.75),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                size: 30,
                color: _C.ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey, $_firstName!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.style(
                  26,
                  weight: FontWeight.w800,
                  color: _C.ink,
                ),
              ),
              Text('Selamat Datang', style: AppText.style(14, color: _C.sub)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const NotificationScreen())),
          child: SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 28,
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _C.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_notifCount',
                      style: AppText.style(
                        12,
                        weight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------- hero
  Widget _buildHero(int done) {
    final remaining = _totalLevels - done;
    return _Block(
      radius: 26,
      lipHeight: 7,
      lip: _C.tileLip,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_C.tileTop, _C.tileMid],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: done / _totalLevels),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => CustomPaint(
                  painter: _HeroRingPainter(v),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(v * 100).round()}%',
                          style: AppText.style(
                            22,
                            weight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'selesai',
                          style: AppText.style(
                            10.5,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Perjalanan Budaya',
                    style: AppText.style(
                      17,
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$done dari $_totalLevels level selesai',
                    style: AppText.style(
                      13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      remaining == 0
                          ? 'Sertifikat terbuka!'
                          : '$remaining level lagi menuju sertifikat',
                      style: AppText.style(
                        11.5,
                        weight: FontWeight.w700,
                        color: _C.lime,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, [String? trailing]) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppText.style(18, weight: FontWeight.w800, color: _C.ink),
          ),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing,
              style: AppText.style(13, weight: FontWeight.w800, color: _C.ink),
            ),
          ),
      ],
    );
  }

  // ------------------------------------------------------- koleksi game
  /// Tiap lingkaran = satu level. Cincin hijau terisi sesuai progres level itu:
  /// penuh kalau selesai, sebagian kalau sedang dikerjakan, kosong kalau belum.
  Widget _buildCollection(int done) {
    return ValueListenableBuilder<Map<int, double>>(
      valueListenable: LevelProgress.byLevel,
      builder: (_, partial, _) {
        return LayoutBuilder(
          builder: (_, c) {
            const gap = 8.0;
            final s = (c.maxWidth - gap * (_totalLevels - 1)) / _totalLevels;
            return Row(
              children: [
                for (var i = 0; i < _totalLevels; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  _Medal(
                    index: i,
                    size: s,
                    progress: i < done ? 1.0 : (partial[i] ?? 0.0),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------- leaderboard
  Widget _buildRankRow(_Rank r) {
    final mirrored = r.place.isEven;
    final me = (AuthService.current?.name ?? '').trim().toLowerCase();
    final isMe = me.isNotEmpty && me == r.name.toLowerCase();

    final rank = SizedBox(
      width: 58,
      height: 62,
      child: _Block(
        radius: 14,
        lip: _C.rankLip,
        gradient: const LinearGradient(colors: [_C.rankFill, _C.rankFill]),
        child: Center(
          child: Text(
            '${r.place}',
            style: AppText.style(
              30,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    final info = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: mirrored
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          'Peringkat ${r.place}',
          style: AppText.style(
            11.5,
            weight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 1),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                r.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.style(
                  14,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _C.lime,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Kamu',
                  style: AppText.style(
                    10,
                    weight: FontWeight.w800,
                    color: _C.tileTop,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );

    final score = Text(
      '${r.score}/$_totalLevels',
      style: AppText.style(22, weight: FontWeight.w800, color: Colors.white),
    );

    final bar = Expanded(
      child: SizedBox(
        height: 62,
        child: _Block(
          radius: 16,
          lip: _C.barLip,
          gradient: const LinearGradient(colors: [_C.barLeft, _C.barRight]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: mirrored
                  ? [score, const SizedBox(width: 12), Expanded(child: info)]
                  : [Expanded(child: info), const SizedBox(width: 12), score],
            ),
          ),
        ),
      ),
    );

    return Row(
      children: mirrored
          ? [bar, const SizedBox(width: 4), rank]
          : [rank, const SizedBox(width: 4), bar],
    );
  }
}

// ---------------------------------------------------------------------------
/// Kotak 3D: lapisan atas (gradasi) dengan "bibir" hijau muda di bawahnya.
class _Block extends StatelessWidget {
  const _Block({
    required this.child,
    required this.gradient,
    required this.lip,
    this.radius = 22,
    this.lipHeight = 6,
  });

  final Widget child;
  final Gradient gradient;
  final Color lip;
  final double radius;
  final double lipHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: lipHeight),
      decoration: BoxDecoration(
        color: lip,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );
  }
}

/// Kartu angka ringkas (ikon + angka + label).
class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return _Block(
      radius: 20,
      lipHeight: 5,
      lip: _C.tileLip,
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_C.tileTop, _C.tileBottom],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _C.lime, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: AppText.style(
                      26,
                      weight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: AppText.style(
                      13,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cincin kemajuan di kartu hero.
class _HeroRingPainter extends CustomPainter {
  const _HeroRingPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 6;

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..color = Colors.white.withValues(alpha: 0.16),
    );
    if (value > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * value,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..color = _C.lime,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeroRingPainter old) => old.value != value;
}

/// Medali level: cincin hijau yang terisi sesuai progres (0 - 1).
class _Medal extends StatelessWidget {
  const _Medal({
    required this.index,
    required this.size,
    required this.progress,
  });
  final int index;
  final double size;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final collected = progress >= 1;
    final started = progress > 0 && !collected;

    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: Duration(milliseconds: 700 + index * 120),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: collected
                      ? _C.gold.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: collected ? 12 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CustomPaint(
              painter: _MedalRingPainter(v),
              child: Padding(
                padding: EdgeInsets.all(size * 0.14),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: collected ? const Color(0xFFFFF1CF) : Colors.white,
                    border: Border.all(
                      color: collected ? _C.gold : _C.track,
                      width: 1.6,
                    ),
                  ),
                  child: Center(
                    child: collected
                        ? Icon(
                            Icons.theater_comedy_rounded,
                            size: size * 0.4,
                            color: _C.gold,
                          )
                        : started
                        ? Text(
                            '${(v * 100).round()}%',
                            style: AppText.style(
                              size * 0.2,
                              weight: FontWeight.w800,
                              color: _C.green,
                            ),
                          )
                        : Icon(
                            Icons.lock_outline_rounded,
                            size: size * 0.3,
                            color: _C.track,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Lv ${index + 1}',
          style: AppText.style(
            11,
            weight: collected ? FontWeight.w800 : FontWeight.w500,
            color: collected ? _C.ink : _C.sub,
          ),
        ),
      ],
    );
  }
}

class _MedalRingPainter extends CustomPainter {
  const _MedalRingPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 5.0;
    final c = size.center(Offset.zero);
    final r = size.width / 2 - stroke / 2 - 1;

    // Jalur kosong (abu muda).
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = _C.track,
    );
    // Bagian hijau yang sudah terisi, mulai dari atas searah jarum jam.
    if (value > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * value.clamp(0.0, 1.0),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = _C.green,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MedalRingPainter old) => old.value != value;
}
