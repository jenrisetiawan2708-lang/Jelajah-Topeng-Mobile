import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/asset_image_box.dart';
import '../../shared/widgets/dark_button.dart';
import '../../shared/widgets/dark_card.dart';
import '../../shared/widgets/gradient_background.dart';
import 'game_clue_screen.dart';
import 'game_header.dart';

class GameMatchScreen extends StatefulWidget {
  const GameMatchScreen({super.key});

  @override
  State<GameMatchScreen> createState() => _GameMatchScreenState();
}

class _GameMatchScreenState extends State<GameMatchScreen> {
  // Topeng (kolom kiri), urut dari atas
  static const _maskImages = [
    'assets/images/mask_hijau.png',
    'assets/images/mask_merah.png',
    'assets/images/mask_kuning.png',
  ];

  // Deskripsi ke-i cocok dengan topeng ke-i (teks, ukuran font desain)
  static const _descs = [
    ('tokoh utama yang baik dan damai', 26.0),
    ('Gagah, Merah, Pemberani dan Pemarah', 22.0),
    ('Pasangan panji, halus, lembut', 26.0),
  ];

  // _descRow[d] = baris tempat deskripsi ke-d sedang ditampilkan (awalnya acak)
  final List<int> _descRow = [0, 2, 1];
  final List<bool> _matched = [false, false, false];
  int? _selMask; // topeng yang sedang terbuka menunggu pasangannya
  int? _wrongDesc; // deskripsi salah yang terbuka sebentar
  bool _busy = false;

  void _tapMask(int i) {
    if (_busy || _matched[i] || _selMask == i) return;
    setState(() => _selMask = i);
  }

  Future<void> _tapDesc(int d) async {
    if (_busy || _selMask == null || _matched[d]) return;
    _busy = true;

    if (d == _selMask) {
      // COCOK: dua kartu tetap terbuka
      setState(() {
        _matched[d] = true;
        _selMask = null;
      });
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      // geser deskripsi ke baris topengnya (tukar tempat)
      setState(() {
        final other = _descRow.indexOf(d); // deskripsi yang sekarang ada di baris d
        final tmp = _descRow[d];
        _descRow[d] = d;
        _descRow[other] = tmp;
      });
    } else {
      // TIDAK COCOK: buka sebentar lalu tutup lagi
      setState(() => _wrongDesc = d);
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() {
        _wrongDesc = null;
        _selMask = null;
      });
    }
    _busy = false;
  }

  void _check() {
    if (_busy || !_matched.every((m) => m)) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const GameClueScreen(
          level: 3,
          title: 'Jejak Sang Panji',
          score: 3,
          text: 'WAJAH BOLEH BERBEDA, TETAPI SETIAP WAJAH MEMILIKI CERITA',
          imagePath: 'assets/images/clue_3.png',
          glowSize: 378,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const GameHeader(title: 'Jejak Sang Panji', score: 2),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 24, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInstruction(),
                      const SizedBox(height: 16),
                      LayoutBuilder(builder: _buildGrid),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                child: DarkButton(
                  text: 'Cek Jawaban',
                  height: 58,
                  fontSize: 24,
                  radius: 30,
                  onPressed: _check,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DarkCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 52),
        child: Text(
          'Tap topeng, lalu tap deskripsi yang cocok',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, BoxConstraints c) {
    final w = c.maxWidth;
    final cardW = (w - 70) / 2;
    final cardH = cardW * 378 / 407;
    final pitch = cardH + 7.5;
    final rightX = 26 + cardW + 21;
    final k = cardW / 160; // skala font mengikuti lebar layar

    final children = <Widget>[];

    // Kolom kiri: topeng
    for (var i = 0; i < 3; i++) {
      children.add(
        Positioned(
          left: 26,
          top: i * pitch,
          width: cardW,
          height: cardH,
          child: _buildMaskCard(i),
        ),
      );
    }

    // Kolom kanan: deskripsi (bisa bergeser baris)
    for (var d = 0; d < 3; d++) {
      children.add(
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          left: rightX,
          top: _descRow[d] * pitch,
          width: cardW,
          height: cardH,
          child: _buildDescCard(d, k),
        ),
      );
    }

    return SizedBox(
      width: w,
      height: pitch * 3,
      child: Stack(children: children),
    );
  }

  Widget _buildMaskCard(int i) {
    return GestureDetector(
      onTap: () => _tapMask(i),
      child: _FlipCard(
        open: _matched[i] || _selMask == i,
        highlight: _matched[i],
        front: Padding(
          padding: const EdgeInsets.all(8),
          child: AssetImageBox(path: _maskImages[i], fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildDescCard(int d, double k) {
    return GestureDetector(
      onTap: () => _tapDesc(d),
      child: _FlipCard(
        open: _matched[d] || _wrongDesc == d,
        highlight: _matched[d],
        front: Padding(
          padding: EdgeInsets.symmetric(horizontal: 9 * k),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _descs[d].$1,
              style: GoogleFonts.plusJakartaSans(fontSize: _descs[d].$2 * k),
            ),
          ),
        ),
      ),
    );
  }
}

// Kartu yang bisa dibalik: tertutup (hijau tua, "?") <-> terbuka (putih)
class _FlipCard extends StatelessWidget {
  const _FlipCard({
    required this.open,
    required this.highlight,
    required this.front,
  });

  final bool open;
  final bool highlight; // true = sudah cocok (garis tepi hijau tebal)
  final Widget front;

  Widget _front() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: highlight
            ? Border.all(color: const Color(0xFF00FF00), width: 3.5)
            : Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: front,
    );
  }

  Widget _back() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary, width: 1.5),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkGreen, AppColors.midGreen],
        ),
      ),
      child: Text(
        '?',
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 56,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: open ? 1 : 0),
      duration: const Duration(milliseconds: 350),
      builder: (context, v, _) {
        final showFront = v > 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(v * math.pi),
          child: showFront
              // sisi depan dibalik lagi supaya tidak tampil terbalik
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: _front(),
                )
              : _back(),
        );
      },
    );
  }
}