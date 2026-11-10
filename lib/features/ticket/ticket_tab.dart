import 'package:flutter/material.dart';
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PackageSelectScreen(initial: p)),
    );
  }

  void _openQr() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TicketDetailScreen()),
    );
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
              _toggle(),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 130),
                  children: _view == _TiketView.riwayat
                      ? [for (final o in _orders) _orderCard(o)]
                      : [for (final p in kPackages) _paketCard(p)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          _segment('Pesan Tiket', _TiketView.pesan),
          _segment('Riwayat Pesanan', _TiketView.riwayat),
        ],
      ),
    );
  }

  Widget _segment(String label, _TiketView v) {
    final on = _view == v;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _view = v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? AppColors.forest : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            style: AppText.style(
              14,
              weight: on ? FontWeight.w700 : FontWeight.w500,
              color: on ? Colors.white : AppColors.forest,
            ),
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
          Text(
            o.jadwal,
            style: AppText.style(12, color: AppColors.muted),
          ),
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
                Text(
                  p.info,
                  style: AppText.style(12, color: AppColors.muted),
                ),
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
          style: AppText.style(13, weight: FontWeight.w700, color: Colors.white),
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