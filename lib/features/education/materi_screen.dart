import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/gradient_background.dart';
import 'edu_header.dart';
import 'edu_style.dart';
import 'education_data.dart';
import 'reading_screen.dart';

class MateriScreen extends StatelessWidget {
  const MateriScreen({super.key, required this.materi});

  final Materi materi;

  BoxDecoration _cardDecoration(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: EduColors.olive, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const EduHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      Text(
                        'Tentang Materi',
                        style: GoogleFonts.plusJakartaSans(
                          color: EduColors.title,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        materi.description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pelajari Materi',
                            style: GoogleFonts.plusJakartaSans(
                              color: EduColors.title,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${materi.readings.length} Bacaan',
                            style: GoogleFonts.plusJakartaSans(
                              color: EduColors.muted,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      for (var i = 0; i < materi.readings.length; i++)
                        _buildReadingTile(context, i),
                      const SizedBox(height: 8),
                      _buildProgressCard(),
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

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
      decoration: _cardDecoration(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MATERI ${materi.number}',
            style: GoogleFonts.plusJakartaSans(
              color: EduColors.red,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            materi.title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              color: EduColors.title,
              fontSize: 29,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'oleh ${materi.author}',
            style: GoogleFonts.plusJakartaSans(
              color: EduColors.muted,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  // Lingkaran status: 0 = selesai, 1 = sedang dibaca, 2+ = belum dimulai
  Widget _buildStatusCircle(int i) {
    Color bg;
    Widget child;
    if (i == 0) {
      bg = EduColors.done;
      child = const Icon(Icons.check, color: Colors.white, size: 22);
    } else if (i == 1) {
      bg = EduColors.gold;
      child = const Icon(Icons.check, color: Colors.black, size: 22);
    } else {
      bg = EduColors.beige;
      child = Text(
        '${i + 1}',
        style: GoogleFonts.plusJakartaSans(
          color: EduColors.muted,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: Center(child: child),
    );
  }

  Widget _buildReadingTile(BuildContext context, int i) {
    final r = materi.readings[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReadingScreen(materi: materi, index: i),
          ),
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: _cardDecoration(30),
          child: Row(
            children: [
              _buildStatusCircle(i),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.menuTitle,
                      style: GoogleFonts.plusJakartaSans(
                        color: EduColors.title,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Bacaan',
                      style: GoogleFonts.plusJakartaSans(
                        color: EduColors.muted,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: EduColors.muted, size: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: _cardDecoration(32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Belajar · 67%',
                style: GoogleFonts.plusJakartaSans(
                  color: EduColors.title,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '2 dari 3 materi selesai',
                style: GoogleFonts.plusJakartaSans(
                  color: EduColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const EduBar(value: 0.67, color: EduColors.gold, height: 10),
        ],
      ),
    );
  }
}