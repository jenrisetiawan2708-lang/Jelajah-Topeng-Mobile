import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/widgets/dark_button.dart';
import '../../shared/widgets/dark_card.dart';
import '../../shared/widgets/gradient_background.dart';
import 'game_clue_screen.dart';
import 'game_header.dart';

/// Level 3: cocokkan topeng dengan deskripsinya.
class GameMatchScreen extends StatefulWidget {
  const GameMatchScreen({super.key});

  @override
  State<GameMatchScreen> createState() => _GameMatchScreenState();
}

class _GameMatchScreenState extends State<GameMatchScreen> {
  static const _masks = [
    'assets/images/mask_hijau.png',
    'assets/images/mask_merah.png',
    'assets/images/mask_kuning.png',
  ];

  static const _descs = [
    'tokoh utama yang baik dan damai',
    'Pasangan panji, halus, lembut',
    'Gagah, Merah, Pemberani dan Pemarah',
  ];

  /// Jawaban benar: topeng ke-i cocok dengan deskripsi ke-_answer[i].
  static const _answer = [0, 2, 1];

  static const _hi = Color(0xFF5BE04F);
  static const _line = Color(0xFF66AA5A);
  static const _red = Color(0xFFD93025);

  int? _picked; // topeng yang sedang dipilih
  final Map<int, int> _pairs = {}; // topeng -> deskripsi
  bool _wrong = false;

  void _tapMask(int i) {
    setState(() {
      _wrong = false;
      _pairs.remove(i); // pilih ulang topeng = lepas pasangannya
      _picked = _picked == i ? null : i;
    });
  }

  void _tapDesc(int j) {
    final m = _picked;
    if (m == null) return;
    setState(() {
      _wrong = false;
      _pairs.removeWhere((_, d) => d == j); // satu deskripsi satu topeng
      _pairs[m] = j;
      _picked = null;
    });
  }

  bool _isRight(int mask) => _pairs[mask] == _answer[mask];

  void _check() {
    if (_pairs.length < _masks.length) return;
    final ok = [for (var i = 0; i < _masks.length; i++) _isRight(i)]
        .every((e) => e);
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GameClueScreen(level: 3)),
      );
    } else {
      setState(() => _wrong = true);
    }
  }

  int? _maskOfDesc(int j) {
    for (final e in _pairs.entries) {
      if (e.value == j) return e.key;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ready = _pairs.length == _masks.length;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const GameHeader(title: 'Jejak Sang Panji', score: 2),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: DarkCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Text(
                    'Tap topeng, lalu tap deskripsi yang cocok',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                  child: Column(
                    children: [
                      for (var i = 0; i < _masks.length; i++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: i < _masks.length - 1 ? 10 : 0,
                            ),
                            child: Row(
                              children: [
                                Expanded(child: _maskTile(i)),
                                const SizedBox(width: 12),
                                Expanded(child: _descTile(i)),
                              ],
                            ),
                          ),
                        ),
                      if (_wrong) ...[const SizedBox(height: 10), _errorBox()],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
                child: Opacity(
                  opacity: ready ? 1 : 0.6,
                  child: DarkButton(
                    text: 'Cek Jawaban',
                    height: 58,
                    fontSize: 20,
                    radius: 30,
                    onPressed: ready ? _check : () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(int number, {bool bad = false}) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bad ? _red : const Color(0xFF2D4A1E),
      ),
      child: Text(
        '$number',
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  BoxDecoration _tileDeco({
    required bool picked,
    required bool paired,
    required bool bad,
  }) {
    Color color = _line;
    double width = 1.1;
    if (bad) {
      color = _red;
      width = 3;
    } else if (paired) {
      color = _hi;
      width = 3;
    } else if (picked) {
      color = _line;
      width = 3;
    }
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: color, width: width),
      boxShadow: [
        BoxShadow(
          color: (paired || picked)
              ? color.withValues(alpha: 0.35)
              : Colors.black.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _maskTile(int i) {
    final paired = _pairs.containsKey(i);
    final bad = _wrong && paired && !_isRight(i);
    return GestureDetector(
      onTap: () => _tapMask(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: _tileDeco(picked: _picked == i, paired: paired, bad: bad),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Image.asset(
                  _masks[i],
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.theater_comedy_rounded,
                    size: 48,
                    color: _line,
                  ),
                ),
              ),
            ),
            if (paired)
              Positioned(top: 8, left: 8, child: _badge(i + 1, bad: bad)),
          ],
        ),
      ),
    );
  }

  Widget _descTile(int j) {
    final m = _maskOfDesc(j);
    final paired = m != null;
    final bad = _wrong && paired && !_isRight(m);
    return GestureDetector(
      onTap: () => _tapDesc(j),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: _tileDeco(picked: false, paired: paired, bad: bad),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Text(
                      _descs[j],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (paired)
              Positioned(top: 8, right: 8, child: _badge(m + 1, bad: bad)),
          ],
        ),
      ),
    );
  }

  Widget _errorBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE9E7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Belum tepat. Coba lagi!',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFC0392B),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Petunjuk: Perhatikan warna dan karakter wajah',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF6B4A47),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
