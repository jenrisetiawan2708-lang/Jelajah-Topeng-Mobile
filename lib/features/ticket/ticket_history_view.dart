import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/payment_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text.dart';
import 'booking/booking_data.dart' show monthsShortId;
import 'refund/ticket_detail_screen.dart';

/// Format rupiah: 120000 -> Rp120.000
String rupiah(num amount) {
  final s = amount.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final left = s.length - i;
    buf.write(s[i]);
    if (left > 1 && left % 3 == 1) buf.write('.');
  }
  return 'Rp$buf';
}

/// Isi tab "Riwayat Pesanan". Data dari GET /api/payments/mine.
class TicketHistoryView extends StatefulWidget {
  const TicketHistoryView({super.key, required this.onReorder});

  /// Dipanggil saat "Pesan Lagi" ditekan, dengan nama paketnya.
  final void Function(String packageName) onReorder;

  @override
  State<TicketHistoryView> createState() => _TicketHistoryViewState();
}

class _TicketHistoryViewState extends State<TicketHistoryView> {
  late Future<List<PaymentOrder>> _future = PaymentService.mine();

  Future<void> _reload() async {
    setState(() => _future = PaymentService.mine());
    await _future.catchError((_) => <PaymentOrder>[]);
  }

  String _date(String iso) {
    final d = DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '';
    return '${d.day} ${monthsShortId[d.month - 1]} ${d.year}';
  }

  /// (label, status terkonfirmasi?)
  (String, bool) _label(String status) {
    switch (status) {
      case 'paid':
        return ('Terkonfirmasi', true);
      case 'pending':
        return ('Menunggu', false);
      case 'expired':
        return ('Kedaluwarsa', false);
      case 'refunded':
        return ('Dikembalikan', false);
      default:
        return ('Gagal', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PaymentOrder>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          final msg = snap.error is ApiException
              ? (snap.error as ApiException).message
              : 'Gagal memuat riwayat pesanan.';
          return _message(msg, action: 'Coba lagi');
        }
        final orders = snap.data ?? const <PaymentOrder>[];
        if (orders.isEmpty) {
          return _message('Belum ada pesanan. Pesan tiket pertamamu sekarang!');
        }
        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: [for (final o in orders) _orderCard(context, o)],
          ),
        );
      },
    );
  }

  Widget _message(String text, {String? action}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppText.style(14, color: AppColors.muted),
            ),
            if (action != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: _reload, child: Text(action)),
            ],
          ],
        ),
      ),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: const Color(0xFFCFE7B0), width: 1.2),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  Widget _badge(String text, bool confirmed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: confirmed ? const Color(0xFFDFF3C8) : const Color(0xFFE6E8E3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: AppText.style(
          11,
          weight: FontWeight.w700,
          color: confirmed ? const Color(0xFF2E6B1E) : AppColors.muted,
        ),
      ),
    );
  }

  Widget _orderCard(BuildContext context, PaymentOrder o) {
    final (label, confirmed) = _label(o.status);
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
                  o.itemName,
                  style: AppText.style(
                    16,
                    weight: FontWeight.w800,
                    color: AppColors.forest,
                  ),
                ),
              ),
              _badge(label, confirmed),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Dipesan ${_date(o.createdAt)}',
            style: AppText.style(12, color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  rupiah(o.amount),
                  style: AppText.style(
                    18,
                    weight: FontWeight.w800,
                    color: AppColors.forest,
                  ),
                ),
              ),
              confirmed
                  ? _filled(
                      'Lihat QR Tiket',
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TicketDetailScreen(),
                        ),
                      ),
                    )
                  : _outlined('Pesan Lagi', () => widget.onReorder(o.itemName)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filled(String label, VoidCallback onTap) {
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

  Widget _outlined(String label, VoidCallback onTap) {
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
