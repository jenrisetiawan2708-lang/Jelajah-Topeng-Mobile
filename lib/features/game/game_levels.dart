import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game_quiz_screen.dart' show ClueReveal;
import 'game_widgets.dart';

// =====================================================================
// Bagian bersama
// =====================================================================

enum _RowState { idle, correct, wrong }

const _bright = Color(0xFF52E052);

Widget _stagger(Animation<double> parent, int i, Widget child) {
  final begin = (0.05 + i * 0.1).clamp(0.0, 0.7);
  final end = (begin + 0.3).clamp(0.0, 1.0);
  final a = CurvedAnimation(
    parent: parent,
    curve: Interval(begin, end, curve: Curves.easeOutCubic),
  );
  return FadeTransition(
    opacity: a,
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(a),
      child: child,
    ),
  );
}

class _HintBox extends StatelessWidget {
  const _HintBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: GameColors.wrongBar.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          color: GameColors.wrongBg,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 10, color: GameColors.wrongBar),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Belum tepat. Coba lagi!',
                          style: gameText(
                            16,
                            weight: FontWeight.w800,
                            color: GameColors.wrongText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(text, style: gameText(12.5, height: 1.3)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// LEVEL 3: cocokkan topeng dengan deskripsinya
// =====================================================================

/// Ganti nama file sesuai aset topengmu di assets/images/.
const _maskAssets = <String>[
  'assets/images/topeng_panji.png',
  'assets/images/topeng_klana.png',
  'assets/images/topeng_sekartaji.png',
];
const _maskFallbackColors = <Color>[
  Color(0xFF8DB88A),
  Color(0xFFB8403A),
  Color(0xFFE2C46B),
];

/// Deskripsi ke-i cocok dengan topeng ke-i.
const _descs = <String>[
  'tokoh utama yang baik dan damai',
  'Gagah, Merah, Pemberani dan Pemarah',
  'Pasangan panji, halus, lembut',
];

/// Urutan awal deskripsi di kolom kanan (semuanya salah posisi).
const _startRows = <int>[2, 0, 1];

class GameMatchScreen extends StatefulWidget {
  const GameMatchScreen({
    super.key,
    required this.gems,
    this.title = 'Jejak Sang Panji',
    this.clueText = 'WAJAH BOLEH BERBEDA, TETAPI SETIAP WAJAH MEMILIKI CERITA',
    this.clueImage = 'assets/images/clue_buku.png',
  });

  final int gems;
  final String title;
  final String clueText;
  final String clueImage;

  @override
  State<GameMatchScreen> createState() => _GameMatchScreenState();
}

class _GameMatchScreenState extends State<GameMatchScreen>
    with TickerProviderStateMixin {
  /// _rows[r] = id deskripsi yang sekarang berada di baris r.
  final List<int> _rows = List.of(_startRows);
  final Set<int> _touched = {};
  int? _selMask;
  int? _selDesc;
  List<_RowState> _states = List.filled(3, _RowState.idle);
  String? _message;
  bool _checking = false;
  bool _solved = false;

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final AnimationController _win = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void dispose() {
    _enter.dispose();
    _shake.dispose();
    _win.dispose();
    super.dispose();
  }

  void _clearFeedback() {
    _states = List.filled(3, _RowState.idle);
    _message = null;
  }

  void _tapMask(int r) {
    if (_checking) return;
    if (_selDesc != null) {
      _pair(r, _selDesc!);
    } else {
      setState(() => _selMask = _selMask == r ? null : r);
      HapticFeedback.selectionClick();
    }
  }

  void _tapDesc(int d) {
    if (_checking) return;
    if (_selMask != null) {
      _pair(_selMask!, d);
    } else {
      setState(() => _selDesc = _selDesc == d ? null : d);
      HapticFeedback.selectionClick();
    }
  }

  /// Pindahkan deskripsi [d] ke baris [r]; deskripsi lama saling tukar.
  void _pair(int r, int d) {
    setState(() {
      final from = _rows.indexOf(d);
      final prev = _rows[r];
      _rows[r] = d;
      _rows[from] = prev;
      _touched
        ..add(d)
        ..add(prev);
      _selMask = null;
      _selDesc = null;
      _clearFeedback();
    });
    HapticFeedback.mediumImpact();
  }

  void _check() {
    if (_checking) return;
    final res = [
      for (var r = 0; r < 3; r++)
        _rows[r] == r ? _RowState.correct : _RowState.wrong,
    ];
    final good = res.where((e) => e == _RowState.correct).length;
    setState(() {
      _states = res;
      _selMask = null;
      _selDesc = null;
      _message = good == 3
          ? null
          : '$good dari 3 pasangan sudah benar. Yang bertanda merah masih salah, coba tukar lagi!';
    });
    if (good == 3) {
      _checking = true;
      HapticFeedback.mediumImpact();
      _win.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _solved = true);
      });
    } else {
      HapticFeedback.heavyImpact();
      _shake.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Column(
            children: [
              GameHeader(
                title: widget.title,
                gems: widget.gems + (_solved ? 1 : 0),
              ),
              Expanded(
                child: _solved
                    ? ClueReveal(
                        image: widget.clueImage,
                        text: widget.clueText,
                        clueNumber: widget.gems + 1,
                        onNext: () => Navigator.of(context).pop(true),
                      )
                    : _buildGame(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
            children: [
              _stagger(
                _enter,
                0,
                GameDarkPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Tap topeng, lalu tap deskripsi yang cocok',
                      textAlign: TextAlign.center,
                      style: gameText(
                        15,
                        weight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _stagger(_enter, 1, _buildBoard()),
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: _message == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _HintBox(text: _message!),
                      ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
          child: GameButton(
            text: 'Cek Jawaban',
            onPressed: _checking ? null : _check,
          ),
        ),
      ],
    );
  }

  Widget _buildBoard() {
    return LayoutBuilder(
      builder: (context, c) {
        const rowH = 116.0;
        const gap = 12.0;
        final descLeft = rowH + 10;
        final descW = c.maxWidth - descLeft;
        return SizedBox(
          height: rowH * 3 + gap * 2,
          child: Stack(
            children: [
              for (var r = 0; r < 3; r++)
                Positioned(
                  left: 0,
                  top: r * (rowH + gap),
                  width: rowH,
                  height: rowH,
                  child: _maskCard(r),
                ),
              for (var d = 0; d < 3; d++)
                AnimatedPositioned(
                  key: ValueKey('desc$d'),
                  duration: const Duration(milliseconds: 480),
                  curve: Curves.easeInOutCubic,
                  left: descLeft,
                  top: _rows.indexOf(d) * (rowH + gap),
                  width: descW,
                  height: rowH,
                  child: _descCard(d),
                ),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _cardDeco({
    required Color border,
    required double width,
    required bool glow,
    Color fill = Colors.white,
  }) {
    return BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: border, width: width),
      boxShadow: [
        BoxShadow(
          color: border.withValues(alpha: glow ? 0.55 : 0.30),
          offset: const Offset(0, 3),
          blurRadius: glow ? 10 : 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _motion(int row, Widget child) {
    final st = _states[row];
    return AnimatedBuilder(
      animation: Listenable.merge([_shake, _win]),
      builder: (_, c) {
        final dx = st == _RowState.wrong
            ? math.sin(_shake.value * math.pi * 6) * 8 * (1 - _shake.value)
            : 0.0;
        final t = ((_win.value - row * 0.15) / 0.3).clamp(0.0, 1.0);
        final pulse = st == _RowState.correct
            ? 1 + 0.06 * math.sin(t * math.pi)
            : 1.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(scale: pulse, child: c),
        );
      },
      child: child,
    );
  }

  Widget _maskCard(int r) {
    final st = _states[r];
    final selected = _selMask == r;
    final border = st == _RowState.wrong
        ? GameColors.wrong
        : st == _RowState.correct
        ? GameColors.green
        : selected
        ? _bright
        : GameColors.greenLine;
    return _motion(
      r,
      GestureDetector(
        onTap: () => _tapMask(r),
        child: AnimatedScale(
          scale: selected ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: _cardDeco(
              border: border,
              width: selected || st != _RowState.idle ? 2.6 : 1.2,
              glow: selected,
              fill: selected ? const Color(0xFFF1FAE6) : Colors.white,
            ),
            child: Image.asset(
              _maskAssets[r],
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                decoration: BoxDecoration(
                  color: _maskFallbackColors[r],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.theater_comedy_rounded,
                  color: Colors.white70,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _descCard(int d) {
    final r = _rows.indexOf(d);
    final st = _states[r];
    final selected = _selDesc == d;
    final highlighted = selected || _touched.contains(d);
    final border = st == _RowState.wrong
        ? GameColors.wrong
        : st == _RowState.correct
        ? GameColors.green
        : highlighted
        ? _bright
        : GameColors.greenLine;
    return _motion(
      r,
      GestureDetector(
        onTap: () => _tapDesc(d),
        child: AnimatedScale(
          scale: selected ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            alignment: Alignment.centerLeft,
            decoration: _cardDeco(
              border: border,
              width: highlighted || st != _RowState.idle ? 2.6 : 1.2,
              glow: highlighted,
              fill: selected ? const Color(0xFFF1FAE6) : Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(_descs[d], style: gameText(15.5, height: 1.25)),
                ),
                if (st != _RowState.idle)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(
                      st == _RowState.correct
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: st == _RowState.correct
                          ? GameColors.green
                          : GameColors.wrong,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// LEVEL 4: isi titik "Ken Dedes"
// =====================================================================

const _fillBefore = '"Ken Dedes tinggal di sebuah desa bernama ';
const _fillAfter =
    ', tempat ia dikenal memiliki kecantikan & aura yang memancar hingga terdengar oleh Tunggul Ametung."';
const _fillOptions = <String>['POLOWIJEN', 'KEDIRI', 'TUMAPEL'];
const _fillCorrect = 0;
const _fillHint = 'Daerah dari Kampung Topeng ini berada dimana';

class GameFillScreen extends StatefulWidget {
  const GameFillScreen({
    super.key,
    required this.gems,
    this.title = 'Jejak Sang Panji',
    this.clueText = 'KECANTIKAN DAPAT MENJADI BAGIAN DARI SEBUAH KISAH, DAN SEBUAH KISAH DAPAT MELAHIRKAN SANG LEGENDA',
    this.clueImage = 'assets/images/Mask group.png',
  });

  final int gems;
  final String title;
  final String clueText;
  final String clueImage;

  @override
  State<GameFillScreen> createState() => _GameFillScreenState();
}

class _GameFillScreenState extends State<GameFillScreen>
    with TickerProviderStateMixin {
  int? _selected;
  _RowState _state = _RowState.idle;
  bool _checking = false;
  bool _solved = false;

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final AnimationController _win = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _enter.dispose();
    _shake.dispose();
    _win.dispose();
    super.dispose();
  }

  void _select(int i) {
    if (_checking) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selected = i;
      _state = _RowState.idle;
    });
  }

  void _check() {
    if (_selected == null || _checking) return;
    if (_selected == _fillCorrect) {
      setState(() {
        _state = _RowState.correct;
        _checking = true;
      });
      HapticFeedback.mediumImpact();
      _win.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (mounted) setState(() => _solved = true);
      });
    } else {
      setState(() => _state = _RowState.wrong);
      HapticFeedback.heavyImpact();
      _shake.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Column(
            children: [
              GameHeader(
                title: widget.title,
                gems: widget.gems + (_solved ? 1 : 0),
              ),
              Expanded(
                child: _solved
                    ? ClueReveal(
                        image: widget.clueImage,
                        text: widget.clueText,
                        clueNumber: widget.gems + 1,
                        onNext: () => Navigator.of(context).pop(true),
                      )
                    : _buildGame(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGame() {
    final blank = _selected == null ? '______' : _fillOptions[_selected!];
    final blankColor = _state == _RowState.wrong
        ? const Color(0xFFFFB4AB)
        : _selected == null
        ? Colors.white
        : const Color(0xFFB6F28A);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
            children: [
              _stagger(
                _enter,
                0,
                GameDarkPanel(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text.rich(
                      TextSpan(
                        style: gameText(
                          15,
                          weight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.45,
                        ),
                        children: [
                          const TextSpan(text: _fillBefore),
                          TextSpan(
                            text: blank,
                            style: gameText(
                              15,
                              weight: FontWeight.w800,
                              color: blankColor,
                              height: 1.45,
                            ).copyWith(decoration: TextDecoration.underline),
                          ),
                          const TextSpan(text: _fillAfter),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _stagger(
                _enter,
                1,
                Text(
                  'Kartu Tersedia',
                  style: gameText(17, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < _fillOptions.length; i++)
                _stagger(_enter, 2 + i, _optionCard(i)),
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: _state != _RowState.wrong
                    ? const SizedBox(width: double.infinity)
                    : const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: _HintBox(text: 'Petunjuk: $_fillHint?'),
                      ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
          child: GameButton(
            text: 'Cek Jawaban',
            onPressed: _selected == null || _checking ? null : _check,
          ),
        ),
      ],
    );
  }

  Widget _optionCard(int i) {
    final selected = _selected == i;
    final st = selected ? _state : _RowState.idle;
    final border = st == _RowState.wrong
        ? GameColors.wrong
        : st == _RowState.correct
        ? GameColors.green
        : selected
        ? _bright
        : GameColors.greenLine;

    return AnimatedBuilder(
      animation: Listenable.merge([_shake, _win]),
      builder: (_, child) {
        final dx = st == _RowState.wrong
            ? math.sin(_shake.value * math.pi * 6) * 8 * (1 - _shake.value)
            : 0.0;
        final pulse = st == _RowState.correct
            ? 1 + 0.05 * math.sin(_win.value * math.pi)
            : 1.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(scale: pulse, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: GestureDetector(
          onTap: () => _select(i),
          child: AnimatedScale(
            scale: selected && st == _RowState.idle ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: st == _RowState.wrong
                    ? const Color(0xFFFFF4F3)
                    : selected
                    ? const Color(0xFFF1FAE6)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border, width: selected ? 2.4 : 1.2),
                boxShadow: [
                  BoxShadow(
                    color: border.withValues(alpha: 0.40),
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(child: Text(_fillOptions[i], style: gameText(15))),
                  if (st == _RowState.correct)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: GameColors.green,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// LEVEL 5: tebak kesenian dari motif Batik Topeng
// =====================================================================

/// Ganti nama file sesuai aset di assets/images/.
const _batikImage = 'assets/images/batik_topeng.png';
const _batikCaption =
    'Sumber inspirasi utama motif pada Batik Topeng Malangan berasal dari ekspresi kesenian...';
const _batikOptions = <String>['Tari Pendet', 'Wayang Kulit', 'Wayang Topeng'];
const _batikCorrect = 2;
const _batikHint = 'Perhatikan dengan detail gambar nya';

class GameBatikScreen extends StatefulWidget {
  const GameBatikScreen({
    super.key,
    required this.gems,
    this.title = 'Jejak Sang Panji',
    this.clueText = 'AKU TUMBUH DARI TANAH, MEMBAWA KEINDAHAN, DAN MENJADI BAGIAN DARI CERITA YANG DIWARISKAN',
    this.clueImage = 'assets/images/clue_tanaman.png',
  });

  final int gems;
  final String title;
  final String clueText;
  final String clueImage;

  @override
  State<GameBatikScreen> createState() => _GameBatikScreenState();
}

class _GameBatikScreenState extends State<GameBatikScreen>
    with TickerProviderStateMixin {
  int? _selected;
  _RowState _state = _RowState.idle;
  bool _checking = false;
  bool _solved = false;

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final AnimationController _win = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _enter.dispose();
    _shake.dispose();
    _win.dispose();
    super.dispose();
  }

  void _select(int i) {
    if (_checking) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selected = i;
      _state = _RowState.idle;
    });
  }

  void _check() {
    if (_selected == null || _checking) return;
    if (_selected == _batikCorrect) {
      setState(() {
        _state = _RowState.correct;
        _checking = true;
      });
      HapticFeedback.mediumImpact();
      _win.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (mounted) setState(() => _solved = true);
      });
    } else {
      setState(() => _state = _RowState.wrong);
      HapticFeedback.heavyImpact();
      _shake.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Column(
            children: [
              GameHeader(
                title: widget.title,
                gems: widget.gems + (_solved ? 1 : 0),
              ),
              Expanded(
                child: _solved
                    ? ClueReveal(
                        image: widget.clueImage,
                        text: widget.clueText,
                        clueNumber: widget.gems + 1,
                        onNext: () => Navigator.of(context).pop(true),
                      )
                    : _buildGame(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
            children: [
              _stagger(_enter, 0, _buildBanner()),
              const SizedBox(height: 24),
              for (var i = 0; i < _batikOptions.length; i++)
                _stagger(
                  _enter,
                  1 + i,
                  _ChoiceCard(
                    text: _batikOptions[i],
                    selected: _selected == i,
                    state: _selected == i ? _state : _RowState.idle,
                    animation: Listenable.merge([_shake, _win]),
                    shake: _shake,
                    win: _win,
                    onTap: () => _select(i),
                  ),
                ),
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: _state != _RowState.wrong
                    ? const SizedBox(width: double.infinity)
                    : const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: _HintBox(text: 'Petunjuk: $_batikHint'),
                      ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
          child: GameButton(
            text: 'Cek Jawaban',
            onPressed: _selected == null || _checking ? null : _check,
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return GameDarkPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: SizedBox(
              height: 130,
              width: double.infinity,
              child: Image.asset(
                _batikImage,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFF2B4F26),
                  child: const Icon(
                    Icons.texture_rounded,
                    color: Colors.white38,
                    size: 56,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                _batikCaption,
                style: gameText(
                  11.5,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu pilihan jawaban (pilih, salah bergetar, benar berdenyut).
class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.text,
    required this.selected,
    required this.state,
    required this.animation,
    required this.shake,
    required this.win,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final _RowState state;
  final Listenable animation;
  final Animation<double> shake;
  final Animation<double> win;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = state == _RowState.wrong
        ? GameColors.wrong
        : state == _RowState.correct
        ? GameColors.green
        : selected
        ? _bright
        : GameColors.greenLine;

    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) {
        final dx = state == _RowState.wrong
            ? math.sin(shake.value * math.pi * 6) * 8 * (1 - shake.value)
            : 0.0;
        final pulse = state == _RowState.correct
            ? 1 + 0.05 * math.sin(win.value * math.pi)
            : 1.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(scale: pulse, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedScale(
            scale: selected && state == _RowState.idle ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
              decoration: BoxDecoration(
                color: state == _RowState.wrong
                    ? const Color(0xFFFFF4F3)
                    : selected
                    ? const Color(0xFFF1FAE6)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border, width: selected ? 2.4 : 1.2),
                boxShadow: [
                  BoxShadow(
                    color: border.withValues(alpha: 0.40),
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(child: Text(text, style: gameText(15))),
                  if (state == _RowState.correct)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: GameColors.green,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
