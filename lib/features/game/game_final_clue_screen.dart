import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/theme/app_text.dart';
import '../auth/auth_service.dart';
import 'game_clues.dart';
import 'game_celebration.dart';

// ---------------------------------------------------------------------------
// Warna dan komponen bersama untuk layar-layar akhir game.
// ---------------------------------------------------------------------------
class _G {
  static const bgTop = Color(0xFFD2EEA4);
  static const bgMid = Color(0xFFF4FAEA);
  static const bgBottom = Color(0xFFFFFFFF);
  static const dark = Color(0xFF2D4A1E);
  static const mid = Color(0xFF3F6B2C);
  static const lip = Color(0xFF6AA83A);
  static const border = Color(0xFFCFE7B0);
  static const green = Color(0xFF66AA5A);
  static const red = Color(0xFFC0392B);
  static const redSoft = Color(0xFFFBE9E7);
  static const gold = Color(0xFFD9A441);
  static const gem = Color(0xFFF7CF68);
  static const muted = Color(0xFF7A7F74);
}

class _GameBg extends StatelessWidget {
  const _GameBg({required this.child, this.celebrate = false});
  final Widget child;
  final bool celebrate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_G.bgTop, _G.bgMid, _G.bgBottom],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(child: child),
          if (celebrate)
            const Positioned.fill(child: IgnorePointer(child: GameConfetti())),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    Widget glass({required Widget child, double? size}) => Container(
      width: size,
      height: 48,
      padding: size == null ? const EdgeInsets.symmetric(horizontal: 18) : null,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        shape: size != null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: size == null ? BorderRadius.circular(24) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: glass(
              size: 48,
              child: const Icon(
                Icons.chevron_left_rounded,
                size: 30,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.style(
                18,
                weight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          glass(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond_rounded, size: 20, color: _G.gem),
                const SizedBox(width: 6),
                Text(
                  '5/5',
                  style: AppText.style(
                    16,
                    weight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkBtn extends StatelessWidget {
  const _DarkBtn({
    required this.text,
    required this.onTap,
    this.width,
    this.height = 54,
  });
  final String text;
  final VoidCallback onTap;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          gradient: const LinearGradient(colors: [_G.dark, _G.mid]),
          boxShadow: const [BoxShadow(color: _G.lip, offset: Offset(0, 3))],
        ),
        child: Text(
          text,
          style: AppText.style(
            15,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

Route<T> _fade<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 300),
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (_, a, _, child) =>
      FadeTransition(opacity: a, child: child),
);

// ===========================================================================
// 1) Semua clue + kolom jawaban
// ===========================================================================
class GameFinalClueScreen extends StatefulWidget {
  const GameFinalClueScreen({super.key});

  @override
  State<GameFinalClueScreen> createState() => _GameFinalClueScreenState();
}

class _GameFinalClueScreenState extends State<GameFinalClueScreen> {
  final _answer = TextEditingController();
  bool _wrong = false;

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  void _check() {
    FocusScope.of(context).unfocus();
    final a = _answer.text.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (a.contains('sekartaji')) {
      Navigator.of(context).pushReplacement(_fade(const _CorrectScreen()));
    } else {
      setState(() => _wrong = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _G.bgTop,
      body: _GameBg(
        child: Column(
          children: [
            const _TopBar(title: 'Jejak Sang Panji'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                children: [
                  for (var i = 0; i < gameClues.length; i++) ...[
                    _ClueCard(number: i + 1, text: gameClues[i]),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _G.dark,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(color: _G.lip, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Text(
                        'Isi Jawaban',
                        style: AppText.style(
                          11,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _wrong ? _G.red : _G.border,
                        width: _wrong ? 2 : 1.4,
                      ),
                    ),
                    child: TextField(
                      controller: _answer,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) {
                        if (_wrong) setState(() => _wrong = false);
                      },
                      onSubmitted: (_) => _check(),
                      style: AppText.style(
                        16,
                        weight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Siapa yang kamu temukan?',
                        hintStyle: AppText.style(
                          15,
                          color: const Color(0xFFB0B5AA),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 20,
                        ),
                      ),
                    ),
                  ),
                  if (_wrong) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      decoration: BoxDecoration(
                        color: _G.redSoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Belum tepat. Coba lagi!',
                            style: AppText.style(
                              12,
                              weight: FontWeight.w800,
                              color: _G.red,
                            ),
                          ),
                          Text(
                            'Petunjuk: Gabungkan semua clue di atas',
                            style: AppText.style(
                              11,
                              color: const Color(0xFF6B4A47),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: _DarkBtn(text: 'Cek Jawaban', height: 56, onTap: _check),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClueCard extends StatelessWidget {
  const _ClueCard({required this.number, required this.text});
  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _G.border, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clue $number',
            style: AppText.style(
              12,
              weight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            text,
            style: AppText.style(13, color: Colors.black, height: 1.3),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// 2) Jawaban benar: Dewi Sekartaji
// ===========================================================================
class _CorrectScreen extends StatelessWidget {
  const _CorrectScreen();

  /// Taruh gambar medali di assets/images/dewi_sekartaji.png (opsional).
  static const _asset = 'assets/images/reward_dewi.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _G.bgTop,
      body: _GameBg(
        child: Column(
          children: [
            const _TopBar(title: 'Jejak Sang Panji'),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.7, end: 1),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutBack,
                    builder: (_, v, child) => Opacity(
                      opacity: v.clamp(0.0, 1.0),
                      child: Transform.scale(scale: v, child: child),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 290,
                          height: 290,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Color(0xFFFFEBC2), Color(0xFFF6FAE9)],
                            ),
                          ),
                          child: Image.asset(
                            _asset,
                            width: 230,
                            height: 230,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF9A6B3F),
                                border: Border.all(
                                  color: const Color(0xFFD9A441),
                                  width: 8,
                                ),
                              ),
                              child: const Icon(
                                Icons.face_3_rounded,
                                size: 110,
                                color: Color(0xFFFFE2B8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'DEWI SEKARTAJI',
                          style: AppText.style(
                            20,
                            weight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Selamat! Kalian berhasil menemukan Sang Putri dari kisah Panji.',
                          textAlign: TextAlign.center,
                          style: AppText.style(14, color: Colors.black),
                        ),
                        const SizedBox(height: 16),
                        _DarkBtn(
                          text: 'Klaim Reward',
                          width: 150,
                          height: 46,
                          onTap: () => Navigator.of(context)
                              .pushReplacement(_fade(const _RewardScreen())),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 3) Reward
// ===========================================================================
class _RewardScreen extends StatelessWidget {
  const _RewardScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _G.bgTop,
      body: _GameBg(
        child: Column(
          children: [
            const _TopBar(title: 'Jejak Sang Panji'),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutBack,
                    builder: (_, v, child) => Opacity(
                      opacity: v.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 0.8 + 0.2 * v,
                        child: child,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFF1CF),
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            size: 56,
                            color: _G.gold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'SELAMAT!!',
                          style: AppText.style(
                            22,
                            weight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Anda Mendapatkan sertifikat karena telah Menamatkan Game Jejak Sang Panji, dan menemukan Dewi Sekartaji',
                          textAlign: TextAlign.center,
                          style: AppText.style(
                            15,
                            color: Colors.black,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _DarkBtn(
                          text: 'Next',
                          width: 110,
                          height: 44,
                          onTap: () => Navigator.of(
                            context,
                          ).pushReplacement(_fade(const _CertificateScreen())),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 4) Sertifikat
// ===========================================================================
class _CertificateScreen extends StatelessWidget {
  const _CertificateScreen();

  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String get _name {
    final n = AuthService.current?.name.trim() ?? '';
    return n.isEmpty ? 'Peserta' : n;
  }

  String get _date {
    final d = DateTime.now();
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  String get _number {
    final d = DateTime.now();
    final id = AuthService.current?.id ?? _name;
    final tail = (id.hashCode.abs() % 1000).toString().padLeft(3, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return 'JTP-$mm$dd-$tail';
  }

  Future<void> _download() async {
    final doc = pw.Document();
    pw.Widget line(String t, double s, {bool bold = false}) => pw.Text(
      t,
      style: pw.TextStyle(
        fontSize: s,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    );
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (_) => pw.Center(
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              line('SERTIFIKAT', 14, bold: true),
              pw.SizedBox(height: 10),
              line('Game Jejak Sang Panji', 30, bold: true),
              pw.SizedBox(height: 6),
              line('Berhasil menyelesaikan seluruh pemberhentian', 14),
              pw.SizedBox(height: 28),
              line('Diberikan kepada', 12),
              pw.SizedBox(height: 4),
              line(_name, 26, bold: true),
              pw.SizedBox(height: 28),
              line('Diterbitkan: $_date', 12),
              pw.SizedBox(height: 4),
              line('Nomor Sertifikat: $_number', 12),
            ],
          ),
        ),
      ),
    );
    final bytes = await doc.save();
    const file = 'Sertifikat_Jejak_Sang_Panji.pdf';
    try {
      await Printing.sharePdf(bytes: bytes, filename: file);
    } catch (_) {
      await Printing.layoutPdf(onLayout: (_) async => bytes, name: file);
    }
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.style(12, color: _G.muted)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppText.style(
              13,
              weight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _G.bgTop,
      body: _GameBg(
        child: Column(
          children: [
            const _TopBar(title: 'Sertifikat'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  Text(
                    'Sertifikat 1',
                    style: AppText.style(
                      15,
                      weight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _G.green, width: 1.6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _G.gold,
                                border: Border.all(
                                  color: const Color(0xFFB98A2E),
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Game Jejak Sang Panji',
                                    style: AppText.style(
                                      15,
                                      weight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Berhasil menyelesaikan seluruh pemberhentian',
                                    style: AppText.style(11, color: _G.muted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 26, color: Color(0xFFEFEFEF)),
                        _row('Penerima', _name),
                        _row('Diterbitkan', _date),
                        _row('Nomor Sertifikat', _number),
                        const SizedBox(height: 14),
                        _DarkBtn(
                          text: 'Unduh PDF',
                          height: 48,
                          onTap: _download,
                        ),
                      ],
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
