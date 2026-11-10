import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/gradient_background.dart';
import '../exploration/exploration_screen.dart';
import '../game/game_map_screen.dart';
import '../profile/profile_screen.dart';
import '../ticket/ticket_screen.dart';
import 'edu_header.dart';
import 'edu_style.dart';
import 'education_data.dart';
import 'materi_screen.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  void _onNav(BuildContext context, int i) {
    if (i == 0) {
      Navigator.of(context).pop(); // kembali ke Beranda
    } else if (i == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GameMapScreen()),
      );
    } else if (i == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TicketScreen()),
      );
    } else if (i == 4) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Tombol peta -> halaman Eksplorasi
                  EduHeader(
                    showMap: true,
                    onMap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ExplorationScreen(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 130),
                      children: [
                        for (final m in materiList) _buildTile(context, m),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: AppBottomNav(
                  currentIndex: 1,
                  onTap: (i) => _onNav(context, i),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, Materi m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MateriScreen(materi: m)),
        ),
        child: Container(
          height: 92,
          padding: const EdgeInsets.fromLTRB(24, 0, 18, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.primary, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MATERI ${m.number}',
                      style: GoogleFonts.plusJakartaSans(
                        color: EduColors.materi,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      m.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${m.author} - ${m.readings.length} Sub Bab',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 34, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}