import 'package:flutter/material.dart';
import '../flow_widgets.dart';
import 'refund_reason_screen.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      header: const FlowHeader(pill: 'Tiket saya'),
      children: [
        FlowCard(
          children: [
            const FlowTitle(
              label: 'TIKET KUNJUNGAN',
              title: 'Detail Tiket',
              subtitle: 'KBP-241026-018',
            ),
            Text('Kampung Budaya Polowijen',
                style: jk(18, w: FontWeight.w800, c: FC.dark)),
            const SizedBox(height: 6),
            const KV('Tanggal kunjungan', '24 Oktober 2026', valueColor: FC.dark),
            const KV('Sesi kunjungan', '09.00–11.00 WIB', valueColor: FC.dark),
            const KV('Jumlah tiket', '2 tiket × Rp50.000', valueColor: FC.dark),
            const FlowLine(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total bayar', style: jk(12, c: FC.muted)),
                Text('Rp100.000',
                    style: jk(17, w: FontWeight.w800, c: FC.dark)),
              ],
            ),
            const FlowLine(),
            const Center(child: QrImage(size: 130)),
            Center(
              child: Text('Ilustrasi QR · bukan tiket yang dapat dipindai',
                  style: jk(9, c: FC.muted)),
            ),
          ],
        ),
        const InfoBox('Rencana berubah? Periksa rincian refund sebelum mengajukan.'),
        FlowButton(
          text: 'Ajukan Refund',
          outlinedRed: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RefundReasonScreen()),
          ),
        ),
        const StepCard(
          label: 'Status tiket',
          right: 'Terjadwal',
          value: 0,
          caption: 'Simpan detail kunjunganmu dengan baik.',
        ),
      ],
    );
  }
}