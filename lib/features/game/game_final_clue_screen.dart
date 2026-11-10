import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/dark_button.dart';
import '../../shared/widgets/gradient_background.dart';
import 'game_header.dart';
import 'game_reward_screen.dart';

class GameFinalClueScreen extends StatefulWidget {
  const GameFinalClueScreen({super.key});

  @override
  State<GameFinalClueScreen> createState() => _GameFinalClueScreenState();
}

class _GameFinalClueScreenState extends State<GameFinalClueScreen> {
  // (judul, isi, ukuran font isi)
  static const _clues = [
    ('Clue 1', 'Aku menyembunyikan wajah, namun mengungkapkan karakter.', 17.0),
    (
      'Clue 2',
      'Aku diwariskan dari masa lalu dan membawa cerita hingga hari ini.',
      17.0,
    ),
    ('Clue 3', 'Wajah boleh berbeda, tetapi setiap wajah memiliki cerita.', 17.0),
    (
      'Clue 4',
      'Kecantikan dapat menjadi bagian dari sebuah kisah, dan sebuah kisah dapat melahirkan legenda.',
      15.0,
    ),
    (
      'Clue 5',
      'Aku tumbuh dari tanah, membawa keindahan, dan menjadi bagian dari cerita yang diwariskan.',
      15.0,
    ),
  ];

  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  bool _wrong = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _check() {
    final answer = _ctrl.text.trim().toLowerCase();
    if (answer.contains('sekartaji')) {
      _focus.unfocus();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GameRewardScreen()),
      );
    } else {
      setState(() => _wrong = true);
    }
  }

  OutlineInputBorder _border(double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: AppColors.primary, width: width),
      );

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < _clues.length; i++) _buildClue(i),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: DarkButton(
                          text: 'Isi Jawaban',
                          width: 94,
                          height: 31,
                          fontSize: 13,
                          radius: 16,
                          onPressed: () => _focus.requestFocus(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        textCapitalization: TextCapitalization.words,
                        style: GoogleFonts.plusJakartaSans(fontSize: 18),
                        onChanged: (_) {
                          if (_wrong) setState(() => _wrong = false);
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 26,
                          ),
                          enabledBorder: _border(1.5),
                          focusedBorder: _border(2.5),
                        ),
                      ),
                      if (_wrong)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 6),
                          child: Text(
                            'Jawaban kamu kurang tepat, coba lagi!',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
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

  Widget _buildClue(int i) {
    final c = _clues[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.fromLTRB(22, 10, 16, 10),
      constraints: const BoxConstraints(minHeight: 78),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c.$1,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(c.$2, style: GoogleFonts.plusJakartaSans(fontSize: c.$3)),
        ],
      ),
    );
  }
}