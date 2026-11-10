import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/dark_button.dart';
import '../../shared/widgets/gradient_background.dart';
import '../education/education_data.dart';
import '../education/materi_screen.dart';
import '../game/game_map_screen.dart';
import '../profile/profile_screen.dart';

class _Spot {
  const _Spot(this.name, this.x, this.y, this.labelOff, this.materiIndex);

  final String name; // nama lokasi (2 baris)
  final double x; // posisi kiri-atas pulau (ukuran desain 990 x 2150)
  final double y;
  final double labelOff; // jarak baris terakhir label ke puncak pulau
  final int? materiIndex; // indeks di materiList (null = belum ada materi)
}

class ExplorationScreen extends StatefulWidget {
  const ExplorationScreen({super.key});

  @override
  State<ExplorationScreen> createState() => _ExplorationScreenState();
}

class _ExplorationScreenState extends State<ExplorationScreen>
    with SingleTickerProviderStateMixin {
  static const _w = 357.0; // lebar pulau (ukuran desain)
  static const _h = 410.0; // tinggi pulau

  // Lokasi 1 - 5, dari bawah ke atas
  static const _spots = [
    _Spot('Makam\nMbah Reni', 322, 1676, 24, 0),
    _Spot('Situs\nSumur Windu', 19, 1192, 16, 1),
    _Spot('Mandala\nEmpu Purwa', 600, 893, 7, 2),
    _Spot('Situs\nJoko Lolo', 48, 627, 8, 3),
    _Spot('Rumah\nBudaya', 473, 377, 40, null),
  ];

  // Irama melayang tiap pulau (kelipatan 1 atau 2 supaya putarannya mulus)
  static const _mult = [1, 2, 1, 2, 1];
  static const _phase = [0.0, 0.2, 0.4, 0.6, 0.8];

  // Satu controller yang berputar terus = pulau melayang tanpa henti
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  int? _selected;
  int _lastSelected = 0; // supaya isi panel tidak hilang saat panel turun

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  void _select(int i) {
    setState(() {
      if (_selected == i) {
        _selected = null;
      } else {
        _selected = i;
        _lastSelected = i;
      }
    });
  }

  void _deselect() {
    if (_selected != null) setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: LayoutBuilder(
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
                // Peta: garis putus-putus + 5 pulau
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 990 * s,
                    height: 2150 * s,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // ketuk area kosong = tutup pilihan
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: _deselect,
                          ),
                        ),
                        CustomPaint(
                          size: Size(990 * s, 2150 * s),
                          painter: _DashPainter(s),
                        ),
                        for (var i = 0; i < _spots.length; i++)
                          _buildIsland(s, i),
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
                      child: _buildHeader(context),
                    ),
                  ),
                ),
                // Panel bawah
                _buildSheet(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildIsland(double s, int i) {
    final spot = _spots[i];
    final selected = _selected == i;

    return Positioned(
      left: spot.x * s,
      top: spot.y * s,
      width: _w * s,
      height: _h * s,
      child: AnimatedBuilder(
        animation: _float,
        builder: (_, child) {
          final p = 2 * math.pi * (_float.value * _mult[i] + _phase[i]);
          return Transform.translate(
            offset: Offset(math.cos(p) * 6 * s, math.sin(p) * 16 * s),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: () => _select(i),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: _IslandImage()),
              // Label ikut melayang bersama pulau
              if (selected)
                Positioned(
                  left: (_w / 2 - 200) * s,
                  top: (spot.labelOff - 90) * s,
                  width: 400 * s,
                  child: Center(child: _buildLabel(spot.name, 52 * s, 9 * s)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Teks hijau dengan garis tepi putih
  Widget _buildLabel(String text, double size, double stroke) {
    final base = GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w800,
      height: 1.15,
    );
    return Stack(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: base.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = stroke
              ..strokeJoin = StrokeJoin.round
              ..color = Colors.white,
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: base.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _circle(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 53,
        height: 53,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.6),
        ),
        child: Icon(icon, size: 30, color: Colors.black),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _circle(Icons.chevron_left, () => Navigator.maybePop(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Eksplorasi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          // Tombol Progres -> peta game Jejak Sang Panji
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GameMapScreen()),
            ),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Text(
                'Progres',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _circle(
            Icons.person_outline,
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheet(BuildContext context) {
    final spot = _spots[_lastSelected];
    final bottom = MediaQuery.of(context).padding.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedSlide(
        offset: _selected != null ? Offset.zero : const Offset(0, 1.05),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 26, 16, 24 + bottom),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFC),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSessionCard(),
              // Rumah Budaya belum punya materi: tombol tidak tampil
              if (spot.materiIndex != null) ...[
                const SizedBox(height: 10),
                DarkButton(
                  text: 'Informasi Pembelajaran',
                  height: 62,
                  fontSize: 20,
                  radius: 31,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          MateriScreen(materi: materiList[spot.materiIndex!]),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sesi Kunjungan', style: GoogleFonts.plusJakartaSans(fontSize: 15)),
          Text(
            'Senin–Jumat, 08.00 WIB s.d. 15.00 WIB',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// Gambar pulau: pakai assets/images/island.png kalau ada,
// kalau belum ada digambar lewat kode.
class _IslandImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/island.png',
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => SizedBox.expand(
        child: CustomPaint(painter: _IslandPainter()),
      ),
    );
  }
}

class _IslandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 357, size.height / 410);

    void facet(List<Offset> pts, Color color) {
      canvas.drawPath(Path()..addPolygon(pts, true), Paint()..color = color);
    }

    // Batu (4 bidang warna)
    facet(const [Offset(3, 62), Offset(20, 62), Offset(160, 398), Offset(144, 408)],
        const Color(0xFFB07F5B));
    facet(const [Offset(20, 62), Offset(194, 62), Offset(194, 330), Offset(176, 372), Offset(160, 398)],
        const Color(0xFF9B6D4B));
    facet(const [Offset(194, 62), Offset(276, 62), Offset(262, 250), Offset(245, 270), Offset(235, 258), Offset(205, 315), Offset(194, 330)],
        const Color(0xFF7A5238));
    facet(const [Offset(276, 62), Offset(357, 62), Offset(296, 288), Offset(275, 270), Offset(262, 250)],
        const Color(0xFF5C3E2A));

    // Rumput: sisi bawah tipis + permukaan + dua bercak
    canvas.drawOval(
      const Rect.fromLTWH(0, 9, 357, 112),
      Paint()..color = const Color(0xFF4E9029),
    );
    const top = Rect.fromLTWH(0, 0, 357, 112);
    canvas.drawOval(
      top,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF7CC443), Color(0xFF63AE34)],
        ).createShader(top),
    );
    canvas.drawOval(
      const Rect.fromLTWH(29, 8, 150, 60),
      Paint()..color = const Color(0xFF8CD843),
    );
    canvas.drawOval(
      const Rect.fromLTWH(165, 41, 150, 58),
      Paint()..color = const Color(0xFF5E9E2E),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// Garis putus-putus hijau antar lokasi (1 -> 2 -> 3 -> 4 -> 5)
class _DashPainter extends CustomPainter {
  _DashPainter(this.s);
  final double s;

  static const _curves = [
    [680.0, 1767.0, 940.0, 1640.0, 800.0, 1290.0, 345.0, 1388.0],
    [265.0, 1195.0, 285.0, 1040.0, 470.0, 1080.0, 660.0, 1140.0],
    [695.0, 898.0, 640.0, 860.0, 480.0, 895.0, 365.0, 880.0],
    [310.0, 632.0, 400.0, 540.0, 470.0, 555.0, 498.0, 538.0],
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