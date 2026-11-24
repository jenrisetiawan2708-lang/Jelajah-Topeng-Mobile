import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';

/// Warna mengikuti halaman Progres Budaya dan Game.
class _C {
  static const bgTop = Color(0xFFD2EEA4);
  static const bgMid = Color(0xFFFBFDF8);
  static const bgBottom = Color(0xFFE0F5C0);

  static const ink = Color(0xFF1E2B12);
  static const sub = Color(0xFF6B7F5A);

  static const dark = Color(0xFF223316);
  static const darkEnd = Color(0xFF3A5527);
  static const lip = Color(0xFF6E9A47);
  static const lime = Color(0xFFB8F08C);

  static const border = Color(0xFFCFE7B0);
  static const green = Color(0xFF4CAF50);
}

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen>
    with SingleTickerProviderStateMixin {
  static const _items = <(String, String)>[
    (
      'Apa itu Jelajah Topeng?',
      'Aplikasi untuk menjelajahi Kampung Budaya Polowijen, belajar '
          'tentang Topeng Malangan, dan bermain game jejak budaya.',
    ),
    (
      'Bagaimana cara membeli tiket?',
      'Buka tab Tiket, pilih paket, isi data, lalu selesaikan pembayaran.',
    ),
    (
      'Apakah bisa refund tiket?',
      'Bisa, melalui menu Riwayat Pesanan sesuai ketentuan refund yang berlaku.',
    ),
    (
      'Bagaimana cara bermain game Jejak Sang Panji?',
      'Buka tab Game, ikuti titik pada peta, lalu selesaikan tantangan '
          'di setiap lokasi untuk mengumpulkan clue.',
    ),
  ];

  /// Indeks pertanyaan yang sedang terbuka (hanya satu pada satu waktu).
  int? _open;

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  /// Muncul pelan dari bawah, bergantian sesuai urutannya.
  Widget _in(int i, Widget child) {
    final b = (0.04 + i * 0.12).clamp(0.0, 0.7);
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            children: [
              _in(0, _buildHeader(context)),
              const SizedBox(height: 20),
              _in(1, _buildHero()),
              const SizedBox(height: 22),
              for (var i = 0; i < _items.length; i++) _in(2 + i, _buildTile(i)),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ header
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.75),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
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
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'FAQ',
            style: AppText.style(26, weight: FontWeight.w800, color: _C.ink),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------- hero
  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: _C.lip,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_C.dark, _C.darkEnd],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: _C.lime,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ada yang ingin ditanyakan?',
                    style: AppText.style(
                      16,
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Temukan jawaban seputar Jelajah Topeng di sini.',
                    style: AppText.style(
                      12.5,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.3,
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

  // -------------------------------------------------------------- tile
  Widget _buildTile(int i) {
    final open = _open == i;
    final (q, a) = _items[i];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: open ? const Color(0xFFF6FCEE) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: open ? _C.green : _C.border,
            width: open ? 2 : 1.2,
          ),
          boxShadow: [
            // bibir tipis di bawah (efek timbul)
            BoxShadow(
              color: (open ? _C.green : _C.border).withValues(alpha: 0.55),
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: open ? 0.14 : 0.08),
              blurRadius: open ? 18 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => setState(() => _open = open ? null : i),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Nomor bergaya kotak hijau tua 3D
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_C.dark, _C.darkEnd],
                          ),
                          boxShadow: const [
                            BoxShadow(color: _C.lip, offset: Offset(0, 3)),
                          ],
                        ),
                        child: Text(
                          '${i + 1}',
                          style: AppText.style(
                            16,
                            weight: FontWeight.w800,
                            color: open ? _C.lime : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q,
                          style: AppText.style(
                            14.5,
                            weight: FontWeight.w700,
                            color: _C.ink,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: open ? 0.5 : 0,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOut,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 28,
                          color: open ? _C.green : _C.sub,
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: open
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              left: 50,
                              right: 6,
                            ),
                            child: Text(
                              a,
                              style: AppText.style(
                                13,
                                color: _C.ink.withValues(alpha: 0.85),
                                height: 1.5,
                              ),
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
