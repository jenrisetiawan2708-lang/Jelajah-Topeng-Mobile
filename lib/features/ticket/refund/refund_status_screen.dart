import 'package:flutter/material.dart';
import '../flow_widgets.dart';

class RefundStatusScreen extends StatelessWidget {
  const RefundStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      header: const FlowHeader(pill: 'Tiket saya'),
      children: [
        FlowCard(
          children: [
            const FlowTitle(
              label: 'PANTAU PENGAJUAN',
              title: 'Status Refund',
              subtitle: 'RF-221026-018 · KBP-241026-018',
            ),
            Text('Kampung Budaya Polowijen',
                style: jk(14, w: FontWeight.w800, c: FC.dark)),
            Text('24 Oktober 2026 · 09.00–11.00 WIB · 2 tiket',
                style: jk(11, c: FC.muted)),
            const FlowLine(),
            _step(
              circle: const Icon(Icons.check, color: Colors.white, size: 22),
              color: FC.button,
              title: 'Diajukan',
              sub: '22 Oktober 2026 · 15.30 WIB',
              lineBelow: true,
              lineColor: FC.button,
            ),
            _step(
              circle: const Icon(Icons.access_time, color: Colors.white, size: 22),
              color: FC.gold,
              title: 'Diproses',
              sub: 'Pengajuan sedang diperiksa dan dana disiapkan untuk dikirim.',
              lineBelow: true,
              lineColor: const Color(0xFFDDDDDD),
            ),
            _step(
              circle: Text('3', style: jk(13, w: FontWeight.w800, c: FC.muted)),
              color: const Color(0xFFE3E6DF),
              title: 'Dana Dikembalikan',
              sub: 'Menunggu transfer ke rekening tujuan.',
              lineBelow: false,
              lineColor: Colors.transparent,
            ),
            const SizedBox(height: 8),
            const InfoBox('Estimasi 3–5 hari kerja'),
          ],
        ),
        FlowCard(
          radius: 20,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dana dikembalikan', style: jk(12, c: FC.muted)),
                Text('Rp75.000',
                    style: jk(16, w: FontWeight.w800, c: FC.dark)),
              ],
            ),
            const FlowLine(),
            const KV('Transfer Bank BCA', '●●●● 4821',
                valueColor: FC.dark, labelSize: 11),
            Text('Atas nama Anisa Putri', style: jk(11, c: FC.muted)),
          ],
        ),
        FlowButton(
          text: 'Kembali ke Tiket Saya',
          onTap: () => backToTickets(context),
        ),
        const StepCard(
          label: 'Progress refund · 67%',
          right: 'Diproses',
          rightColor: FC.gold,
          color: FC.gold,
          value: 0.67,
          caption: 'Pengajuanmu sedang ditangani. Mohon tunggu, ya.',
        ),
      ],
    );
  }

  // Satu langkah di garis waktu (lingkaran + garis penghubung)
  Widget _step({
    required Widget circle,
    required Color color,
    required String title,
    required String sub,
    required bool lineBelow,
    required Color lineColor,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 38,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  child: circle,
                ),
                if (lineBelow)
                  Expanded(child: Container(width: 3, color: lineColor)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: lineBelow ? 12 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: jk(14, w: FontWeight.w800, c: FC.dark)),
                  Text(sub, style: jk(11, c: FC.muted, h: 1.3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}