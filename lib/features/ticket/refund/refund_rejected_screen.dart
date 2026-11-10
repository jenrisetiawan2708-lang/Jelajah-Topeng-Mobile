import 'package:flutter/material.dart';
import '../flow_widgets.dart';

class RefundRejectedScreen extends StatelessWidget {
  const RefundRejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      header: const FlowHeader(title: 'Status Refund', titleColor: FC.dark),
      gap: 14,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: FC.redDark,
            ),
            child: const Icon(Icons.priority_high, color: Colors.white, size: 40),
          ),
        ),
        Column(
          children: [
            Text('Pengajuan Refund Ditolak',
                style: jk(20, w: FontWeight.w800, c: FC.dark)),
            const SizedBox(height: 2),
            Text('Maaf, pengajuanmu belum dapat disetujui.',
                style: jk(12, c: const Color(0xFF555555))),
          ],
        ),
        FlowCard(
          children: [
            Text('ALASAN PENOLAKAN',
                style: jk(11, w: FontWeight.w800, c: FC.red)),
            const SizedBox(height: 6),
            Text(
              'Pengajuan refund melewati batas waktu pembatalan, yaitu maksimal 24 jam sebelum jadwal kunjungan.',
              style: jk(12, h: 1.35),
            ),
            const FlowLine(),
            Text('Ditinjau pada 24 Oktober 2026, 08.15 WIB',
                style: jk(10.5, c: FC.muted)),
          ],
        ),
        FlowCard(
          children: [
            Text('Rincian Pengajuan', style: jk(15, w: FontWeight.w800)),
            const SizedBox(height: 4),
            const KV('Nomor transaksi', 'TRX-241026-001'),
            const SizedBox(height: 2),
            Text('Kampung Budaya Polowijen',
                style: jk(12.5, w: FontWeight.w800, c: FC.dark)),
            Text('24 Oktober 2026 · 09.00 WIB · 2 tiket',
                style: jk(10.5, c: FC.muted)),
            const SizedBox(height: 4),
            const KV('Nominal pengajuan', 'Rp50.000'),
          ],
        ),
        const InfoBox(
          'Tiket kamu tetap aktif dan dapat digunakan sesuai jadwal kunjungan.',
          quote: false,
        ),
      ],
    );
  }
}