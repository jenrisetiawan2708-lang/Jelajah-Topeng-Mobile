import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/gradient_background.dart';
import 'edu_header.dart';
import 'edu_style.dart';
import 'education_data.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key, required this.materi, required this.index});

  final Materi materi;
  final int index; // 0, 1, 2

  // (label status, isi bar 0-1, warna bar, keterangan)
  static const _states = [
    ('✓ Selesai dibaca', 1.0, EduColors.done, 'Hebat! Nilai Budaya sudah kamu baca.'),
    ('Sedang dibaca', 0.5, EduColors.gold, 'Teruskan bacaan Nilai Budaya, yuk!'),
    ('Belum dimulai', 0.0, EduColors.gold, 'Yuk, kenali nilai budaya di sekitar kita.'),
  ];

  Reading get _r => materi.readings[index];

  void _next(BuildContext context) {
    if (index < materi.readings.length - 1) {
      // lanjut ke bacaan berikutnya
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReadingScreen(materi: materi, index: index + 1),
        ),
      );
    } else {
      // bacaan terakhir: kembali ke detail materi
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              EduHeader(onNext: () => _next(context)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    children: [
                      _buildCard(),
                      const SizedBox(height: 14),
                      _buildStatus(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final r = _r;
    final bigQuote = r.quote.length < 60;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: EduColors.olive, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r.label,
            style: GoogleFonts.plusJakartaSans(
              color: EduColors.red,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            r.title,
            style: GoogleFonts.plusJakartaSans(
              color: EduColors.title,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          Text(
            'Bacaan · Teks ilustratif',
            style: GoogleFonts.plusJakartaSans(
              color: EduColors.muted,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 2, color: const Color(0xFFF0EBD8)),
          const SizedBox(height: 10),
          Text(
            r.body,
            style: GoogleFonts.plusJakartaSans(fontSize: 17, height: 1.32),
          ),
          const SizedBox(height: 14),
          // Kotak kutipan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 10, 16, 10),
            decoration: BoxDecoration(
              color: EduColors.quoteBg,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const Icon(Icons.format_quote, color: EduColors.gold, size: 30),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.quote,
                    style: GoogleFonts.plusJakartaSans(
                      color: EduColors.title,
                      fontSize: bigQuote ? 22 : 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus() {
    final s = _states[index.clamp(0, 2)];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bacaan ini',
                style: GoogleFonts.plusJakartaSans(
                  color: EduColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                s.$1,
                style: GoogleFonts.plusJakartaSans(
                  color: EduColors.title,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          EduBar(value: s.$2, color: s.$3, height: 9),
          const SizedBox(height: 8),
          Text(
            s.$4,
            style: GoogleFonts.plusJakartaSans(
              color: EduColors.muted,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}