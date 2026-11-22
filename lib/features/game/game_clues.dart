import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';

/// Satu clue / reward per level. Urutan = level 1 sampai 5. TIDAK berubah-ubah.
class GameClue {
  const GameClue({required this.text, required this.image, this.glow = 340});
  final String text;
  final String image;
  final double glow; // diameter lingkaran cahaya di belakang gambar
}

const kGameClues = <GameClue>[
  GameClue(
    text: 'Aku menyembunyikan wajah, namun mengungkapkan karakter.',
    image: 'assets/images/mask_clue.png',
  ),
  GameClue(
    text: 'Aku diwariskan dari masa lalu dan membawa cerita hingga hari ini.',
    image: 'assets/images/mask_clue_2.png',
  ),
  GameClue(
    text: 'Wajah boleh berbeda, tetapi setiap wajah memiliki cerita.',
    image: 'assets/images/clue_3.png',
    glow: 378,
  ),
  GameClue(
    text: 'Kecantikan dapat menjadi bagian dari sebuah kisah, dan sebuah kisah dapat melahirkan legenda.',
    image: 'assets/images/clue_4.png',
    glow: 371,
  ),
  GameClue(
    text: 'Aku tumbuh dari tanah, membawa keindahan, dan menjadi bagian dari cerita yang diwariskan.',
    image: 'assets/images/clue_5.png',
  ),
];

/// Hanya teksnya (dipakai layar jawaban akhir).
final List<String> gameClues = [for (final c in kGameClues) c.text];

/// Pop-up clue untuk level yang sudah selesai.
/// [onGuess] diisi kalau ada tombol "Tebak Jawaban" (dipakai di level 5).
void showClueSheet(BuildContext context, int level, {VoidCallback? onGuess}) {
  final clue = kGameClues[(level - 1).clamp(0, kGameClues.length - 1)];
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          24,
          14,
          24,
          MediaQuery.of(sheetContext).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Image.asset(
                clue.image,
                height: 110,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox(height: 110),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Clue $level',
              style: AppText.style(
                13,
                weight: FontWeight.w800,
                color: const Color(0xFFC4573F),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              clue.text,
              style: AppText.style(
                18,
                weight: FontWeight.w800,
                color: const Color(0xFF2D4A1E),
                height: 1.3,
              ),
            ),
            if (onGuess != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    onGuess();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D4A1E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'Tebak Jawaban',
                    style: AppText.style(
                      15,
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
    },
  );
}
