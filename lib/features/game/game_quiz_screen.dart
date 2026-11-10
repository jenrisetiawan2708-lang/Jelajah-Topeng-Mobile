import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/dark_button.dart';
import '../../shared/widgets/dark_card.dart';
import '../../shared/widgets/gradient_background.dart';
import 'game_clue_screen.dart';
import 'game_header.dart';

class GameQuizScreen extends StatefulWidget {
  const GameQuizScreen({super.key});

  @override
  State<GameQuizScreen> createState() => _GameQuizScreenState();
}

class _GameQuizScreenState extends State<GameQuizScreen> {
  static const _options = ['Mbah Reni', 'Ki Sujono', 'Dewi Sekartaji'];
  static const _correct = 0; // Mbah Reni
  static const _duration = 30; // detik
  static const _red = Color(0xFFD32F2F);

  int? _selected;
  bool _wrong = false;

  // Pemutar audio (simulasi). TODO: ganti dengan pemutar audio sungguhan
  // (paket audioplayers + file audio kisah di assets).
  int _pos = 0;
  bool _playing = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    if (_playing) {
      _timer?.cancel();
      setState(() => _playing = false);
      return;
    }
    if (_pos >= _duration) _pos = 0;
    setState(() => _playing = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_pos >= _duration - 1) {
        t.cancel();
        setState(() {
          _pos = _duration;
          _playing = false;
        });
      } else {
        setState(() => _pos++);
      }
    });
  }

  String _fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  void _select(int i) => setState(() {
        _selected = i;
        _wrong = false;
      });

  void _check() {
    if (_selected == null) return;
    if (_selected == _correct) {
      _timer?.cancel();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const GameClueScreen(
            level: 1,
            title: 'Makam Mbah Reni',
            score: 1,
            text: 'AKU MENYEMBUNYIKAN WAJAH, NAMUN MENGUNGKAPKAN KARAKTER',
            imagePath: 'assets/images/mask_clue.png',
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
              const GameHeader(title: 'Makam Mbah Reni', score: 0),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAudioCard(),
                      const SizedBox(height: 18),
                      _buildQuestionCard(),
                      const SizedBox(height: 14),
                      for (var i = 0; i < _options.length; i++) _buildOption(i),
                      if (_wrong) _buildFeedback(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                child: Opacity(
                  opacity: _selected == null ? 0.5 : 1,
                  child: DarkButton(
                    text: 'Cek Jawaban',
                    height: 58,
                    fontSize: 22,
                    radius: 30,
                    onPressed: _check,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioCard() {
    final small = GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13);
    final fraction = _pos / _duration;
    return DarkCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Langkah 1: Dengarkan cerita ($_duration detik)',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.edge,
                  ),
                  child: Icon(
                    _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Putar audio kisah',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _playing ? 'Sedang diputar...' : 'Ketuk untuk memutar',
                      style: small,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              const knob = 12.0;
              final left = (c.maxWidth - knob) * fraction;
              return SizedBox(
                height: 14,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      width: c.maxWidth * fraction,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Positioned(
                      left: left,
                      child: Container(
                        width: knob,
                        height: knob,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.edge,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(_pos), style: small),
              Text(_fmt(_duration), style: small),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFD8A5), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Langkah 2: Pilih jawaban',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Siapa yang dipercaya menjaga topeng sakti di kisah ini?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.25,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(int i) {
    final selected = _selected == i;
    final bad = _wrong && selected;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _select(i),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: bad ? const Color(0xFFFFF4F4) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: bad
                  ? _red
                  : (selected ? AppColors.primary : const Color(0xFFBFD8A5)),
              width: bad ? 2.2 : (selected ? 2.4 : 1.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _options[i],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (bad)
                const Icon(Icons.cancel, color: _red, size: 26)
              else if (selected)
                const Icon(Icons.radio_button_checked,
                    color: AppColors.primary, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1B7B7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Belum tepat. Coba lagi!',
            style: GoogleFonts.plusJakartaSans(
              color: _red,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Petunjuk: dengarkan lagi nama tokoh yang disebut di menit pertama.',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF7A2E2E),
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}