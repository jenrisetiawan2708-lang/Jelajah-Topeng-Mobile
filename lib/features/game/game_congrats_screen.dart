import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/dark_button.dart';
import '../../shared/widgets/gradient_background.dart';
import 'game_certificate_screen.dart';
import 'game_header.dart';

class GameCongratsScreen extends StatelessWidget {
  const GameCongratsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const GameHeader(title: 'Jejak Sang Panji', score: 5),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SELAMAT!!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Anda Mendapatkan sertifikat karena telah Menamatkan Game Jejak sang Panji, dan menemukan Dewi Sekartaji',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(fontSize: 18),
                        ),
                        const SizedBox(height: 32),
                        DarkButton(
                          text: 'Next',
                          width: 100,
                          height: 40,
                          fontSize: 16,
                          radius: 20,
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const GameCertificateScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}