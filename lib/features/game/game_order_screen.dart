import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/dark_button.dart';
import '../../shared/widgets/dark_card.dart';
import '../../shared/widgets/gradient_background.dart';
import 'game_clue_screen.dart';
import 'game_header.dart';

class GameOrderScreen extends StatefulWidget {
  const GameOrderScreen({super.key});

  @override
  State<GameOrderScreen> createState() => _GameOrderScreenState();
}

class _GameOrderScreenState extends State<GameOrderScreen>
    with TickerProviderStateMixin {
  static const _cards = [
    ('Memahat', 'Pahat bagian kasar dulu, lalu detail mata, hidung, dan mulut.'),
    ('Mewarnai dan finishing',
        'Beri warna, detail alis dan bibir, pernis, lalu pasang tali.'),
    ('Membuat Pola',
        'Membuat sketsa wajah: bentuk muka, lalu detail mata, hidung, dan mulut.'),
    ('Amplas dan Cat dasar',
        'Haluskan permukaan, lalu lapisi cat dasar agar warna rata.'),
    ('Memilih kayu', 'Pilih kayu yang ringan dan lunak, lalu keringkan dulu.'),
  ];

  // Urutan benar (indeks kartu di atas):
  // Memilih kayu, Membuat Pola, Memahat, Amplas dan Cat dasar, Mewarnai
  static const _order = [4, 2, 0, 3, 1];

  static const _slotColors = [
    Color(0xFF255B28),
    Color(0xFF255B28),
    Color(0xFF255B28),
    Color(0xFF2E7336),
    Color(0xFF2E7336),
  ];

  final _stackKey = GlobalKey();
  final _slotKeys = List.generate(5, (_) => GlobalKey());
  final _cardKeys = List.generate(5, (_) => GlobalKey());

  late final AnimationController _fly = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  final _placed = List<bool>.filled(5, false); // kartu sudah diambil dari daftar
  int _filled = 0; // jumlah kotak jawaban yang sudah terisi
  bool _busy = false;
  int? _flyCard;
  Rect? _flyFrom;
  Rect? _flyTo;
  int? _shakeCard;

  @override
  void dispose() {
    _fly.dispose();
    _shake.dispose();
    super.dispose();
  }

  // Posisi widget relatif terhadap Stack layar
  Rect _rectOf(GlobalKey key) {
    final box = key.currentContext!.findRenderObject() as RenderBox;
    final stack = _stackKey.currentContext!.findRenderObject() as RenderBox;
    final topLeft = stack.globalToLocal(box.localToGlobal(Offset.zero));
    return topLeft & box.size;
  }

  Future<void> _onTapCard(int i) async {
    if (_busy || _filled >= 5 || _placed[i]) return;
    _busy = true;

    if (i == _order[_filled]) {
      // BENAR: kartu terbang ke kotak jawaban
      final from = _rectOf(_cardKeys[i]);
      final to = _rectOf(_slotKeys[_filled]);
      setState(() {
        _flyCard = i;
        _flyFrom = from;
        _flyTo = to;
        _placed[i] = true;
      });
      await _fly.forward(from: 0);
      if (!mounted) return;
      setState(() {
        _filled++;
        _flyCard = null;
      });
    } else {
      // SALAH: kartu bergetar
      setState(() => _shakeCard = i);
      await _shake.forward(from: 0);
      if (!mounted) return;
      setState(() => _shakeCard = null);
    }
    _busy = false;
  }

  void _check() {
    if (_busy || _filled < 5) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const GameClueScreen(
          level: 2,
          title: 'Makam Mbah Reni',
          score: 2,
          text: 'AKU DI WARISKAN DARI MASA LALU, DAN MEMBAWA CERITA HINGGA HARI INI',
          imagePath: 'assets/images/mask_clue_2.png',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          key: _stackKey,
          children: [
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const GameHeader(title: 'Jejak Sang Panji', score: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 24, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DarkCard(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              child: Text(
                                'Seret kartu ke bawah sesuai urutan\nproses membuat topeng yang benar',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 5 kotak jawaban
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                for (var i = 0; i < 5; i++) ...[
                                  if (i > 0) const SizedBox(width: 5.5),
                                  Expanded(child: _buildSlot(i)),
                                ],
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 26, 16, 6),
                            child: Text(
                              _filled == 5
                                  ? 'Tidak ada Kartu Tersedia untuk saat ini'
                                  : 'Kartu Tersedia',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          // Kartu tetap di tempatnya (yang diambil meninggalkan ruang kosong)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var i = 0; i < _cards.length; i++)
                                  SizedBox(
                                    height: 78,
                                    child: _placed[i]
                                        ? const SizedBox()
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            child: _buildCard(i),
                                          ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
            // Kartu yang sedang terbang ke kotak jawaban
            if (_flyCard != null)
              AnimatedBuilder(
                animation: _fly,
                builder: (_, _) {
                  final t = Curves.easeInOutCubic.transform(_fly.value);
                  final rect = Rect.lerp(_flyFrom, _flyTo, t)!;
                  return Positioned.fromRect(
                    rect: rect,
                    child: IgnorePointer(
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            Colors.white,
                            _slotColors[_filled],
                            t,
                          ),
                          borderRadius: BorderRadius.circular(
                            lerpDouble(35, 24, t)!,
                          ),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        child: Opacity(
                          opacity: (1 - t * 1.6).clamp(0.0, 1.0),
                          child: OverflowBox(
                            alignment: Alignment.centerLeft,
                            minWidth: _flyFrom!.width,
                            maxWidth: _flyFrom!.width,
                            minHeight: _flyFrom!.height,
                            maxHeight: _flyFrom!.height,
                            child: _cardContent(_flyCard!),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlot(int i) {
    return Container(
      key: _slotKeys[i],
      height: 65,
      decoration: BoxDecoration(
        color: i < _filled ? _slotColors[i] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildCard(int i) {
    final card = GestureDetector(
      onTap: () => _onTapCard(i),
      child: Container(
        key: _cardKeys[i],
        height: 70,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: AppColors.primary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _cardContent(i),
      ),
    );

    if (_shakeCard != i) return card;
    return AnimatedBuilder(
      animation: _shake,
      builder: (_, child) => Transform.translate(
        offset: Offset(
          math.sin(_shake.value * math.pi * 8) * 10 * (1 - _shake.value),
          0,
        ),
        child: child,
      ),
      child: card,
    );
  }

  Widget _cardContent(int i) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 70,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(35),
              right: Radius.circular(18),
            ),
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Color(0xFF1E4D24), Color(0xFF3B8F43)],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _cards[i].$1,
                  style: GoogleFonts.plusJakartaSans(fontSize: 18),
                ),
                Text(
                  _cards[i].$2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}