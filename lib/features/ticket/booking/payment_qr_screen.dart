import 'dart:async';

import 'package:flutter/material.dart';

import '../flow_widgets.dart';
import 'booking_data.dart';
import 'payment_result_screen.dart';

/// Pembayaran QR (desain Figma "Pembayaran QR").
class PaymentQrScreen extends StatefulWidget {
  const PaymentQrScreen({super.key, required this.data});

  final BookingData data;

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  int _left = 899; // 14:59
  bool _checking = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left <= 1) {
        _finish(false); // waktu habis -> Pembayaran Gagal
      } else {
        setState(() => _left--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _finish(bool success) {
    _timer?.cancel();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            PaymentResultScreen(data: widget.data, success: success),
      ),
    );
  }

  /// "Saya Sudah Bayar".
  /// TODO: ganti dengan GET /api/payments/{orderId}/status ke backend,
  /// lalu _finish(true) jika status "paid", atau tampilkan pesan jika belum.
  Future<void> _paid() async {
    if (_checking) return;
    setState(() => _checking = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    _finish(true);
  }

  String get _clock {
    final m = (_left ~/ 60).toString().padLeft(2, '0');
    final s = (_left % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return FlowScaffold(
      header: const FlowHeader(title: 'Pembayaran', titleColor: FC.dark),
      gap: 14,
      bottom: FlowButton(
        text: _checking ? 'Memeriksa pembayaran...' : 'Saya Sudah Bayar',
        height: 52,
        enabled: !_checking,
        onTap: _paid,
      ),
      children: [_buildSummary(d), _buildQr()],
    );
  }

  Widget _buildSummary(BookingData d) {
    return FlowCard(
      radius: 18,
      children: [
        Text(
          'RINGKASAN PESANAN',
          style: jk(10, w: FontWeight.w800, c: FC.red),
        ),
        const SizedBox(height: 4),
        Text(
          'Kampung Budaya Polowijen',
          style: jk(18, w: FontWeight.w800, c: FC.dark),
        ),
        const SizedBox(height: 6),
        KV('Tanggal kunjungan', dateId(d.date), valueColor: FC.dark),
        KV('Jam kunjungan', '${d.time} WIB', valueColor: FC.dark),
        KV(
          'Jumlah tiket',
          d.package.flatTotal != null
              ? 'Paket tetap (maks. ${d.package.maxPeople} orang)'
              : '${d.tickets} tiket × ${rupiah(d.unitPrice)}',
          valueColor: FC.dark,
        ),
        const FlowLine(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total bayar', style: jk(12, c: FC.muted)),
            Text(
              rupiah(d.total),
              style: jk(20, w: FontWeight.w800, c: FC.button),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQr() {
    return FlowCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      children: [
        Center(
          child: Text(
            'Scan QR untuk membayar',
            style: jk(14, w: FontWeight.w800, c: FC.dark),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            // Mode uji coba: tekan lama QR = simulasi pembayaran berhasil.
            onLongPress: () => _finish(true),
            child: const QrImage(size: 210),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'QRIS',
            style: jk(12, w: FontWeight.w800, c: FC.dark),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: GestureDetector(
            // Mode uji coba: tekan lama waktu = simulasi pembayaran gagal.
            onLongPress: () => _finish(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: FC.gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_filled_rounded,
                    size: 14,
                    color: FC.ink,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Bayar sebelum $_clock',
                    style: jk(11.5, w: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Gunakan aplikasi bank atau e-wallet kamu.',
            textAlign: TextAlign.center,
            style: jk(10, c: FC.muted),
          ),
        ),
      ],
    );
  }
}
