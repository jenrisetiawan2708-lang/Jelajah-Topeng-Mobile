import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../education/education_data.dart';
import '../education/materi_screen.dart';
import '../profile/profile_screen.dart';
import '../progress/progress_screen.dart';

/// Satu pulau/lokasi di peta.
class _Place {
  const _Place(this.name, this.slot, this.materiIndex);
  final String name;

  /// Pusat bagian atas pulau (0..1) dari desain.
  final Offset slot;

  /// Index di materiList. null = belum ada materi (tombol disembunyikan).
  final int? materiIndex;
}

/// Halaman "Eksplorasi Kampung Topeng": peta pulau melayang.
///
/// Tap pulau -> nama tempat muncul. Tap lagi -> panel info kunjungan dan
/// tombol "Informasi Pembelajaran" (membuka halaman materi Education).
class ExplorationScreen extends StatefulWidget {
  const ExplorationScreen({super.key});

  @override
  State<ExplorationScreen> createState() => _ExplorationScreenState();
}

class _ExplorationScreenState extends State<ExplorationScreen>
    with TickerProviderStateMixin {
  static const _groundAsset = 'assets/images/map_ground.png';

  static const _visitHours = 'Senin-Jumat, 08.00 WIB s.d. 15.00 WIB';

  // Urutan: paling bawah -> paling atas.
  static const _places = <_Place>[
    _Place('Makam Mbah Reni', Offset(0.506, 0.805), 0),
    _Place('Situs Sumur Windu', Offset(0.200, 0.580), 1),
    _Place('Mandala Empu Purwa', Offset(0.788, 0.439), 2),
    _Place('Situs Joko Lolo', Offset(0.229, 0.317), 3),
    _Place('Rumah Budaya', Offset(0.659, 0.200), null),
  ];

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  int? _selected;
  bool _panelOpen = false;

  @override
  void dispose() {
    _enter.dispose();
    _float.dispose();
    super.dispose();
  }

  void _onIslandTap(int k) {
    setState(() {
      if (_selected == k) {
        _panelOpen = true; // tap kedua: tampilkan info kunjungan
      } else {
        _selected = k; // tap pertama: tampilkan nama
        _panelOpen = false;
      }
    });
  }

  void _clear() {
    if (_selected == null) return;
    setState(() {
      _selected = null;
      _panelOpen = false;
    });
  }

  void _openMateri() {
    final i = _selected == null ? null : _places[_selected!].materiIndex;
    if (i == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MateriScreen(materi: materiList[i])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD2EEA4), Color(0xFFFBFDF8), Color(0xFFE0F5C0)],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final h = c.maxHeight;
            final iw = math.min(w * 0.36, h * 0.165);
            final ih = iw * 1.18;
            final pts = [
              for (final p in _places) Offset(p.slot.dx * w, p.slot.dy * h),
            ];

            return Stack(
              fit: StackFit.expand,
              children: [
                // Rumput + pohon.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Image.asset(
                      _groundAsset,
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),

                // Tap area kosong: tutup nama/panel.
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _clear,
                  ),
                ),

                // Jalur putus-putus.
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _DashedPathPainter(pts)),
                  ),
                ),

                // Pulau.
                for (var k = 0; k < _places.length; k++)
                  _buildIsland(k, pts[k], iw, ih),

                // Nama tempat (hanya untuk pulau yang dipilih).
                for (var k = 0; k < _places.length; k++)
                  _buildLabel(k, pts[k], iw, h),

                // Header.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildHeader(mq.padding.top),
                ),

                // Panel info kunjungan.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    ignoring: !_panelOpen,
                    child: AnimatedSlide(
                      offset: _panelOpen ? Offset.zero : const Offset(0, 1.1),
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      child: _buildPanel(mq.padding.bottom),
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

  // ------------------------------------------------------------- pulau
  Widget _buildIsland(int k, Offset center, double iw, double ih) {
    final begin = (0.05 + k * 0.12).clamp(0.0, 0.65);
    final a = CurvedAnimation(
      parent: _enter,
      curve: Interval(begin, begin + 0.35, curve: Curves.easeOutBack),
    );
    final selected = _selected == k;

    return Positioned(
      left: center.dx - iw / 2,
      top: center.dy - iw * 0.155,
      width: iw,
      height: ih,
      child: AnimatedBuilder(
        animation: Listenable.merge([_enter, _float]),
        builder: (_, child) {
          final dy = math.sin((_float.value + k * 0.2) * 2 * math.pi) * 5;
          final s = a.value.clamp(0.0, 1.2);
          return Opacity(
            opacity: a.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, dy + (1 - a.value.clamp(0.0, 1.0)) * 40),
              child: Transform.scale(
                scale: 0.6 + 0.4 * s,
                alignment: Alignment.topCenter,
                child: child,
              ),
            ),
          );
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onIslandTap(k),
          child: AnimatedScale(
            scale: selected ? 1.06 : 1.0,
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: CustomPaint(painter: const _IslandPainter()),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------- nama
  Widget _buildLabel(int k, Offset center, double iw, double h) {
    final selected = _selected == k;
    final lw = iw * 1.0;

    const outline = <Shadow>[
      Shadow(color: Colors.white, offset: Offset(1.5, 0)),
      Shadow(color: Colors.white, offset: Offset(-1.5, 0)),
      Shadow(color: Colors.white, offset: Offset(0, 1.5)),
      Shadow(color: Colors.white, offset: Offset(0, -1.5)),
      Shadow(color: Colors.white, offset: Offset(1.2, 1.2)),
      Shadow(color: Colors.white, offset: Offset(-1.2, 1.2)),
      Shadow(color: Colors.white, offset: Offset(1.2, -1.2)),
      Shadow(color: Colors.white, offset: Offset(-1.2, -1.2)),
    ];

    return Positioned(
      left: center.dx - lw / 2,
      width: lw,
      bottom: h - (center.dy + iw * 0.04),
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _float,
          builder: (_, child) {
            final dy = math.sin((_float.value + k * 0.2) * 2 * math.pi) * 5;
            return Transform.translate(offset: Offset(0, dy), child: child);
          },
          child: AnimatedOpacity(
            opacity: selected ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            child: AnimatedScale(
              scale: selected ? 1 : 0.85,
              alignment: Alignment.bottomCenter,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Text(
                _places[k].name,
                textAlign: TextAlign.center,
                style: AppText.style(
                  17,
                  weight: FontWeight.w800,
                  color: const Color(0xFF5BAA55),
                  height: 1.05,
                ).copyWith(shadows: outline),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ header
  Widget _buildHeader(double topInset) {
    Widget chip({required Widget child, VoidCallback? onTap, double? size}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size ?? 56,
          padding: size == null
              ? const EdgeInsets.symmetric(horizontal: 22)
              : null,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.62),
            shape: size != null ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: size == null ? BorderRadius.circular(30) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 0),
      child: Row(
        children: [
          chip(
            size: 56,
            onTap: () => Navigator.of(context).maybePop(),
            child: const Icon(
              Icons.chevron_left_rounded,
              size: 34,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Eksplorasi',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.style(
                19,
                weight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          chip(
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProgressScreen())),
            child: Text(
              'Progres',
              style: AppText.style(
                17,
                weight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 10),
          chip(
            size: 56,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 30,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- panel
  Widget _buildPanel(double bottomInset) {
    final hasMateri =
        _selected != null && _places[_selected!].materiIndex != null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, 18, 18, bottomInset + 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF66AA5A), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sesi Kunjungan',
                  style: AppText.style(11, color: const Color(0xFF6B7A5C)),
                ),
                const SizedBox(height: 2),
                Text(
                  _visitHours,
                  style: AppText.style(
                    14,
                    weight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          if (hasMateri) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _openMateri,
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF42632D), Color(0xFF2E4A21)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E4A21).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'Informasi Pembelajaran',
                  style: AppText.style(
                    16,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pulau melayang: tanah hijau di atas, batu cokelat meruncing di bawah.
class _IslandPainter extends CustomPainter {
  const _IslandPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    final body = Path()
      ..moveTo(0, .16 * w)
      ..lineTo(w, .16 * w)
      ..lineTo(.96 * w, .50 * w)
      ..lineTo(.90 * w, .60 * w)
      ..lineTo(.86 * w, .56 * w)
      ..lineTo(.80 * w, .78 * w)
      ..lineTo(.74 * w, .72 * w)
      ..lineTo(.64 * w, .96 * w)
      ..lineTo(.58 * w, .90 * w)
      ..lineTo(.42 * w, 1.16 * w)
      ..close();

    canvas.save();
    canvas.clipPath(body);
    canvas.drawPath(body, Paint()..color = const Color(0xFF9A7352));
    canvas.drawPath(
      Path()
        ..moveTo(.48 * w, .1 * w)
        ..lineTo(.80 * w, .1 * w)
        ..lineTo(.64 * w, 1.2 * w)
        ..lineTo(.40 * w, 1.2 * w)
        ..close(),
      Paint()..color = const Color(0xFF6E5239),
    );
    canvas.drawPath(
      Path()
        ..moveTo(.80 * w, .1 * w)
        ..lineTo(1.05 * w, .1 * w)
        ..lineTo(1.05 * w, 1.2 * w)
        ..lineTo(.64 * w, 1.2 * w)
        ..close(),
      Paint()..color = const Color(0xFF55402F),
    );
    canvas.drawOval(
      Rect.fromLTWH(0, .06 * w, w, .32 * w),
      Paint()..color = const Color(0x40000000),
    );
    canvas.restore();

    canvas.drawOval(
      Rect.fromLTWH(0, .05 * w, w, .31 * w),
      Paint()..color = const Color(0xFF5F9535),
    );
    canvas.drawOval(
      Rect.fromLTWH(0, 0, w, .31 * w),
      Paint()..color = const Color(0xFF84BF48),
    );
    canvas.drawOval(
      Rect.fromLTWH(.08 * w, .03 * w, .32 * w, .12 * w),
      Paint()..color = const Color(0xFFA2D561),
    );
    canvas.drawOval(
      Rect.fromLTWH(.50 * w, .13 * w, .38 * w, .12 * w),
      Paint()..color = const Color(0xFF6B9E3B),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Jalur lengkung putus-putus antar pulau (bawah -> atas).
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
      ..color = const Color(0xFF66A85A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const dash = 4.0;
    const gap = 7.0;
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        final end = (d + dash).clamp(0.0, m.length).toDouble();
        canvas.drawPath(m.extractPath(d, end), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPathPainter old) => old.p != p;
}
