import 'dart:async';
import 'package:flutter/material.dart';
import '../flow_widgets.dart';
import 'booking_data.dart';
import 'payment_result_screen.dart';
import 'step_bar.dart';

class PaymentQrScreen extends StatefulWidget {
  const PaymentQrScreen({super.key, required this.data});

  final BookingData data;

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  static const _border = Color(0xFFCFE7B0);

  int _left = 899; // 14:59
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
    // TODO: ganti dengan polling GET /api/payments/{orderId}/status
    // ke backend, lalu panggil _finish(true) saat status sudah "paid".
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
        builder: (_) => PaymentResultScreen(data: widget.data, success: success),
      ),
    );
  }

  String get _clock {
    final m = (_left ~/ 60).toString().padLeft(2, '0');
    final s = (_left % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _soon(String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what aktif setelah terhubung ke pembayaran QRIS.')),
    );
  }

  BoxDecoration get _card => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return FlowScaffold(
      header: const FlowHeader(title: 'Pembayaran', titleColor: FC.dark),
      gap: 14,
      bottom: _buildBottom(),
      children: [
        const BookingStepBar(current: 3),
        _buildTotal(d),
        _buildQr(),
        _buildHowTo(),
      ],
    );
  }

  Widget _buildTotal(BookingData d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total pembayaran', style: jk(11.5, c: FC.muted)),
                Text(rupiah(d.total),
                    style: jk(24, w: FontWeight.w800, c: FC.dark)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: FC.gold,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Bayar dalam $_clock',
                style: jk(11.5, w: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _outlined(IconData icon, String text, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: FC.dark, width: 1.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: FC.dark),
              const SizedBox(width: 6),
              Text(text, style: jk(12.5, w: FontWeight.w700, c: FC.dark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQr() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: _card,
      child: Column(
        children: [
          GestureDetector(
            // Mode uji coba: tekan lama QR = simulasi pembayaran berhasil.
            onLongPress: () => _finish(true),
            child: const QrImage(size: 200),
          ),
          const SizedBox(height: 6),
          Text('QRIS · Jelajah Topeng',
              style: jk(12, w: FontWeight.w700, c: FC.dark)),
          const SizedBox(height: 12),
          Row(
            children: [
              _outlined(Icons.download_outlined, 'Simpan QR',
                  () => _soon('Simpan QR')),
              const SizedBox(width: 10),
              _outlined(Icons.account_balance_wallet_outlined, 'Buka e-wallet',
                  () => _soon('Buka e-wallet')),
            ],
          ),
          const SizedBox(height: 10),
          Text('Mode uji coba: tekan lama QR untuk simulasi bayar berhasil.',
              textAlign: TextAlign.center, style: jk(10, c: FC.muted)),
        ],
      ),
    );
  }

  Widget _buildHowTo() {
    const steps = [
      'Simpan QR atau buka aplikasi e-wallet kamu',
      'Pilih Scan QR lalu pilih gambar QR di atas',
      'Konfirmasi nominal. Tiket muncul otomatis di tab Tiket',
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cara membayar', style: jk(14, w: FontWeight.w800, c: FC.dark)),
          const SizedBox(height: 10),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: FC.dark,
                    ),
                    child: Text('${i + 1}',
                        style: jk(11, w: FontWeight.w800, c: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(steps[i], style: jk(12, h: 1.3))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottom() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: FC.dark,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text('Memeriksa pembayaran...',
                  style: jk(14, w: FontWeight.w800, c: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tombol dikunci agar tidak tertekan dua kali. Tiket muncul otomatis.',
          textAlign: TextAlign.center,
          style: jk(10, c: FC.muted),
        ),
      ],
    );
  }
}