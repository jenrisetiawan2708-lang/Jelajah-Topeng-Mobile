import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../shared/widgets/gradient_background.dart';
import 'booking/booking_data.dart';
import 'booking/package_select_screen.dart';
import 'refund/ticket_detail_screen.dart';

enum _TiketView { pesan, riwayat }

class _Order {
  const _Order({
    required this.paket,
    required this.jadwal,
    required this.harga,
    required this.status,
  });
  final String paket;
  final String jadwal;
  final String harga;
  final String status;
}

// Data contoh. Nanti diganti dari GET /api/payments/mine.
const _orders = [
  _Order(
    paket: 'Paket Medayoh',
    jadwal: 'Sabtu, 24 Okt 2026 · 13.00–17.00 WIB · 4 orang',
    harga: 'Rp120.000',
    status: 'Terkonfirmasi',
  ),
  _Order(
    paket: 'Paket Sobo Pawon',
    jadwal: '12 Okt 2026 · 3 orang',
    harga: 'Rp75.000',
    status: 'Selesai',
  ),
];

class TiketTab extends StatefulWidget {
  const TiketTab({super.key});

  @override
  State<TiketTab> createState() => _TiketTabState();
}

class _TiketTabState extends State<TiketTab> {
  _TiketView _view = _TiketView.riwayat;

  void _openPesan([TicketPackage? p]) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PackageSelectScreen(initial: p)));
  }

  void _openQr() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const TicketDetailScreen()));
  }

  TicketPackage? _packageByName(String name) {
    for (final p in kPackages) {
      if (p.name == name) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tiket',
                style: AppText.style(
                  30,
                  weight: FontWeight.w800,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(height: 14),
              _GlassTabSwitch(
                labels: const ['Pesan Tiket', 'Riwayat Pesanan'],
                selectedIndex: _view == _TiketView.pesan ? 0 : 1,
                onChanged: (i) => setState(
                  () => _view = i == 0 ? _TiketView.pesan : _TiketView.riwayat,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: ListView(
                    key: ValueKey(_view),
                    padding: const EdgeInsets.only(bottom: 130),
                    children: _view == _TiketView.riwayat
                        ? [
                            for (var i = 0; i < _orders.length; i++)
                              _FadeSlideIn(
                                index: i,
                                child: _orderCard(_orders[i]),
                              ),
                          ]
                        : [
                            for (var i = 0; i < kPackages.length; i++)
                              _FadeSlideIn(
                                index: i,
                                child: _paketCard(kPackages[i]),
                              ),
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

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: const Color(0xFFCFE7B0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  Widget _badge(String status) {
    final confirmed = status == 'Terkonfirmasi';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: confirmed ? const Color(0xFFDFF3C8) : const Color(0xFFE6E8E3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: AppText.style(
          11,
          weight: FontWeight.w700,
          color: confirmed ? const Color(0xFF2E6B1E) : AppColors.muted,
        ),
      ),
    );
  }

  Widget _orderCard(_Order o) {
    final confirmed = o.status == 'Terkonfirmasi';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  o.paket,
                  style: AppText.style(
                    16,
                    weight: FontWeight.w800,
                    color: AppColors.forest,
                  ),
                ),
              ),
              _badge(o.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(o.jadwal, style: AppText.style(12, color: AppColors.muted)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  o.harga,
                  style: AppText.style(
                    18,
                    weight: FontWeight.w800,
                    color: AppColors.forest,
                  ),
                ),
              ),
              confirmed
                  ? _filledButton('Lihat QR Tiket', _openQr)
                  : _outlinedButton(
                      'Pesan Lagi',
                      () => _openPesan(_packageByName(o.paket)),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paketCard(TicketPackage p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: AppText.style(
                    16,
                    weight: FontWeight.w800,
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(height: 4),
                Text(p.info, style: AppText.style(12, color: AppColors.muted)),
                const SizedBox(height: 8),
                Text(
                  p.priceLabel,
                  style: AppText.style(
                    14,
                    weight: FontWeight.w700,
                    color: AppColors.forest,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _filledButton('Pesan', () => _openPesan(p)),
        ],
      ),
    );
  }

  Widget _filledButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.forest,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Text(
          label,
          style: AppText.style(
            13,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _outlinedButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: AppColors.forest, width: 1.4),
        ),
        child: Text(
          label,
          style: AppText.style(
            13,
            weight: FontWeight.w700,
            color: AppColors.forest,
          ),
        ),
      ),
    );
  }
}

/// Kartu muncul pelan dari bawah, bergantian sesuai urutannya.
class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + index * 90),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 22),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Toggle bergaya kaca: pil hijau tua meluncur, teks berubah halus,
/// dan bisa digeser dengan jari.
class _GlassTabSwitch extends StatefulWidget {
  const _GlassTabSwitch({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  State<_GlassTabSwitch> createState() => _GlassTabSwitchState();
}

class _GlassTabSwitchState extends State<_GlassTabSwitch> {
  static const double _height = 58;
  static const double _pad = 6;
  static const _darkEnd = Color(0xFF47683A);

  int? _pressed;

  void _select(int i) {
    if (i == widget.selectedIndex) return;
    HapticFeedback.selectionClick();
    widget.onChanged(i);
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.labels.length;
    const radius = _height / 2;
    final sel = widget.selectedIndex;

    return Container(
      height: _height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.78),
                  Colors.white.withValues(alpha: 0.42),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 1.2,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, c) {
                final segW = (c.maxWidth - _pad * 2) / n;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (d) {
                    final i = ((d.localPosition.dx - _pad) / segW)
                        .floor()
                        .clamp(0, n - 1);
                    _select(i);
                  },
                  child: Stack(
                    children: [
                      // Pil hijau tua yang meluncur.
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutBack,
                        left: _pad + sel * segW,
                        top: _pad,
                        bottom: _pad,
                        width: segW,
                        child: AnimatedScale(
                          scale: _pressed == sel ? 0.96 : 1,
                          duration: const Duration(milliseconds: 120),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                radius - _pad,
                              ),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.forest, _darkEnd],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.forest.withValues(
                                    alpha: 0.40,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            // Kilau kaca tipis di tepi atas pil.
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: FractionallySizedBox(
                                widthFactor: 0.78,
                                child: Container(
                                  height: 1.6,
                                  margin: const EdgeInsets.only(top: 1.5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0),
                                        Colors.white.withValues(alpha: 0.7),
                                        Colors.white.withValues(alpha: 0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Label.
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: _pad),
                        child: Row(
                          children: [
                            for (var i = 0; i < n; i++)
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: (_) =>
                                      setState(() => _pressed = i),
                                  onTapCancel: () =>
                                      setState(() => _pressed = null),
                                  onTapUp: (_) =>
                                      setState(() => _pressed = null),
                                  onTap: () => _select(i),
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 260,
                                      ),
                                      curve: Curves.easeOut,
                                      style: AppText.style(
                                        i == sel ? 15 : 14,
                                        weight: i == sel
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: i == sel
                                            ? Colors.white
                                            : AppColors.forest,
                                      ),
                                      child: Text(
                                        widget.labels[i],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
