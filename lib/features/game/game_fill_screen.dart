import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/dark_button.dart';
import '../../shared/widgets/dark_card.dart';
import '../../shared/widgets/gradient_background.dart';
import 'game_clue_screen.dart';
import 'game_header.dart';

class GameFillScreen extends StatefulWidget {
  const GameFillScreen({super.key});

  @override
  State<GameFillScreen> createState() => _GameFillScreenState();
}

class _GameFillScreenState extends State<GameFillScreen> {
  static const _options = ['POLOWIJEN', 'KEDIRI', 'TUMAPEL'];
  static const _correct = 0; // POLOWIJEN

  int? _selected;
  bool _wrong = false;

  void _select(int i) {
    setState(() {
      _selected = i;
      _wrong = false;
    });
  }

  void _check() {
    if (_selected == null) return;
    if (_selected == _correct) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const GameClueScreen(
            level: 4,
            title: 'Jejak Sang Panji',
            score: 4,
            text:
                'KECANTIKAN DAPAT MENJADI BAGIAN DARI SEBUAH KISAH, DAN SEBUAH KISAH DAPAT MELAHIRKAN SANG LEGENDA',
            imagePath: 'assets/images/clue_4.png',
            glowSize: 371,
          ),
        ),
      );
    } else {
      setState(() => _wrong = true);
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
              const GameHeader(title: 'Jejak Sang Panji', score: 3),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildQuestion(),
                      const SizedBox(height: 22),
                      Text(
                        'Kartu Tersedia',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (var i = 0; i < _options.length; i++) _buildOption(i),
                      if (_wrong) _buildError(),
                    ],
                  ),
                ),
              ),
              if (!_wrong)
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

  Widget _buildQuestion() {
    return DarkCard(
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 17),
      child: Text(
        '"Ken Dedes tinggal di sebuah desa bernama ______, tempat ia dikenal memiliki kecantikan & aura yang memancar hingga terdengar oleh Tunggul Ametung."',
        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildOption(int i) {
    final selected = _selected == i;
    final bad = _wrong && selected;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _select(i),
        child: Container(
          height: 70,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: bad ? Colors.red : AppColors.primary,
              width: bad ? 2.5 : (selected ? 3 : 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            _options[i],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        'Jawaban kamu kurang tepat, coba lagi!',
        style: GoogleFonts.plusJakartaSans(
          color: Colors.red,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}