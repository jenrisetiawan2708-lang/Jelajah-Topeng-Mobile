import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/payment_service.dart';
import '../flow_widgets.dart';
import 'booking_data.dart';
import 'payment_result_screen.dart';

/// Pembayaran lewat Midtrans (mode SANDBOX).
/// Alur: buat transaksi -> buka halaman Midtrans -> status dicek otomatis.
class PaymentQrScreen extends StatefulWidget {
  const PaymentQrScreen({super.key, required this.data});

  final BookingData data;

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen>
    with WidgetsBindingObserver {
  static const _pollEvery = 4; // detik

  PaymentOrder? _order;
  String? _error;
  bool _creating = true;
  bool _polling = false;
  bool _done = false;
  int _left = 899; // 14:59
  int _tick = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
    _createOrder();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Kembali dari browser/e-wallet: langsung cek status.
    if (state == AppLifecycleState.resumed) _poll();
  }

  void _onTick() {
    if (_order == null || _done) return;
    if (_left <= 1) {
      _finish(false); // waktu habis
      return;
    }
    setState(() => _left--);
    _tick++;
    if (_tick % _pollEvery == 0) _poll();
  }

  Future<void> _createOrder() async {
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final d = widget.data;
      final order = await PaymentService.checkout(
        amount: d.total,
        itemName: d.package.name,
      );
      if (!mounted) return;
      setState(() {
        _order = order;
        _creating = false;
        _left = 899;
        _tick = 0;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _creating = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal membuat pesanan. Coba lagi.';
        _creating = false;
      });
    }
  }

  Future<void> _openPay() async {
    final url = _order?.redirectUrl ?? '';
    if (url.isEmpty) {
      _snack('Halaman pembayaran belum tersedia.');
      return;
    }
    final uri = Uri.parse(url);
    var ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (!ok) ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok) _snack('Tidak bisa membuka halaman pembayaran.');
  }

  Future<void> _poll({bool manual = false}) async {
    final order = _order;
    if (order == null || _polling || _done) return;
    _polling = true;
    try {
      final status = await PaymentService.status(order.orderId);
      if (status == 'paid') {
        _finish(true);
      } else if (status == 'failed' || status == 'expired') {
        _finish(false);
      } else if (manual) {
        _snack(
          'Pembayaran belum diterima. Selesaikan dulu di halaman Midtrans.',
        );
      }
    } on ApiException catch (e) {
      if (manual) _snack(e.message);
    } catch (_) {
      if (manual) _snack('Gagal memeriksa status. Coba lagi.');
    } finally {
      _polling = false;
    }
  }

  void _finish(bool success) {
    if (_done) return;
    _done = true;
    _timer?.cancel();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentResultScreen(
          data: widget.data,
          success: success,
          orderId: _order?.orderId,
        ),
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
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
      bottom: _buildBottom(),
      children: [
        _buildSummary(d),
        if (_error != null) _buildError() else _buildPayCard(),
      ],
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
        KV('Paket', d.package.name, valueColor: FC.dark),
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

  Widget _buildPayCard() {
    return FlowCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      children: [
        Center(
          child: Text(
            'Bayar lewat Midtrans',
            style: jk(14, w: FontWeight.w800, c: FC.dark),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: _creating
              ? const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEAF5E6),
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    size: 52,
                    color: FC.dark,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            _creating
                ? 'Menyiapkan pembayaran...'
                : 'Tekan "Bayar Sekarang" untuk memilih QRIS atau metode lain.',
            textAlign: TextAlign.center,
            style: jk(12, c: FC.muted, h: 1.35),
          ),
        ),
        if (!_creating) ...[
          const SizedBox(height: 12),
          Center(
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
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Status diperiksa otomatis. Mode uji coba (Sandbox): tidak ada uang sungguhan.',
              textAlign: TextAlign.center,
              style: jk(10, c: FC.muted, h: 1.3),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildError() {
    return FlowCard(
      radius: 18,
      children: [
        Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: FC.redDark),
            const SizedBox(width: 10),
            Expanded(
              child: Text(_error ?? '', style: jk(12.5, c: FC.redDark, h: 1.3)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottom() {
    if (_error != null) {
      return FlowButton(text: 'Coba Lagi', height: 52, onTap: _createOrder);
    }
    final ready = _order != null && !_creating;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlowButton(
          text: 'Bayar Sekarang',
          height: 52,
          enabled: ready,
          onTap: _openPay,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: ready ? () => _poll(manual: true) : null,
          child: Opacity(
            opacity: ready ? 1 : 0.5,
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: FC.dark, width: 1.4),
              ),
              child: Text(
                'Saya Sudah Bayar',
                style: jk(14, w: FontWeight.w800, c: FC.dark),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
