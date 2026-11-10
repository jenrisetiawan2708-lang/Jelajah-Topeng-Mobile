import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../flow_widgets.dart';
import 'booking_data.dart';
import 'payment_qr_screen.dart';

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({
    super.key,
    required this.data,
    required this.success,
  });

  final BookingData data;
  final bool success;

  static const _trx = 'TRX-241026-001';

  // Membuat PDF tiket lalu membuka share sheet (simpan / kirim)
  static Future<void> _download(BookingData d) async {
    final doc = pw.Document();
    pw.Widget line(String t, double s, {bool bold = false}) => pw.Text(
          t,
          style: pw.TextStyle(
            fontSize: s,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        );
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            line('TIKET KUNJUNGAN', 12, bold: true),
            pw.SizedBox(height: 6),
            line('Kampung Budaya Polowijen', 24, bold: true),
            pw.SizedBox(height: 20),
            line('Nomor transaksi: $_trx', 14),
            pw.SizedBox(height: 6),
            line('Tanggal kunjungan: ${dateId(d.date)}', 14),
            pw.SizedBox(height: 6),
            line('Jam kunjungan: ${d.time} WIB', 14),
            pw.SizedBox(height: 6),
            line('Jumlah tiket: ${d.tickets} x ${rupiah(d.unitPrice)}', 14),
            pw.SizedBox(height: 6),
            line('Total bayar: ${rupiah(d.total)}', 16, bold: true),
            pw.SizedBox(height: 20),
            line('Tunjukkan tiket ini saat masuk.', 12),
          ],
        ),
      ),
    );
    final Uint8List bytes = await doc.save();
    const name = 'Tiket_Kampung_Budaya_Polowijen.pdf';
    try {
      await Printing.sharePdf(bytes: bytes, filename: name);
    } catch (_) {
      await Printing.layoutPdf(onLayout: (_) async => bytes, name: name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = data;
    final today = dateId(DateTime.now());

    return FlowScaffold(
      header: const SizedBox(height: 8),
      centered: true,
      gap: 14,
      bottom: success
          ? FlowButton(
              text: 'Download Tiket',
              icon: Icons.file_download_outlined,
              height: 52,
              onTap: () => _download(d),
            )
          : FlowButton(
              text: 'Coba Bayar Lagi',
              height: 52,
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => PaymentQrScreen(data: d)),
              ),
            ),
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: success ? FC.button : FC.redDark,
            ),
            child: Icon(success ? Icons.check : Icons.close,
                color: Colors.white, size: 50),
          ),
        ),
        Column(
          children: [
            Text(success ? 'Pembayaran Berhasil' : 'Pembayaran Gagal',
                style: jk(21, w: FontWeight.w800, c: FC.dark)),
            const SizedBox(height: 4),
            Text(
              success
                  ? 'Tiket kamu sudah aktif'
                  : 'Waktu pembayaran telah habis. Silakan coba lagi untuk melanjutkan pesananmu.',
              textAlign: TextAlign.center,
              style: jk(11.5, c: const Color(0xFF555555)),
            ),
          ],
        ),
        FlowCard(
          radius: 18,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rincian Transaksi', style: jk(15, w: FontWeight.w800)),
                if (!success)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE9E7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Gagal',
                        style: jk(10, w: FontWeight.w800, c: FC.redDark)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const KV('Nomor transaksi', _trx),
            KV('Tanggal transaksi', today),
            const KV('Metode pembayaran', 'QRIS'),
            if (success)
              const KV('Status pembayaran', 'Berhasil', valueColor: FC.button),
            const FlowLine(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total bayar', style: jk(12)),
                Text(rupiah(d.total),
                    style: jk(21, w: FontWeight.w800, c: FC.dark)),
              ],
            ),
          ],
        ),
        InfoBox(
          success
              ? '${d.tickets} tiket Kampung Budaya Polowijen untuk ${dateId(d.date)}, pukul ${d.time} WIB. Tunjukkan tiket saat masuk.'
              : 'Tiket belum aktif. Jika saldo kamu terpotong, hubungi bantuan dengan menyertakan nomor transaksi.',
          quote: false,
        ),
      ],
    );
  }
}