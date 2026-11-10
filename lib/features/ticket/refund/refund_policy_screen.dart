import 'package:flutter/material.dart';
import '../flow_widgets.dart';
import 'refund_method_screen.dart';
import 'refund_rejected_screen.dart';

class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key, this.rejected = false});

  final bool rejected; // true = pengajuan <24 jam (dana kembali 0%)

  @override
  Widget build(BuildContext context) {
    const rows = [('>48 jam', '100%'), ('24–48 jam', '75%'), ('<24 jam', '0%')];
    final active = rejected ? 2 : 1;

    return FlowScaffold(
      header: const FlowHeader(pill: 'Refund'),
      children: [
        FlowCard(
          children: [
            const FlowTitle(
              label: 'SEBELUM MELANJUTKAN',
              title: 'Kebijakan & Rincian Dana',
              subtitle: 'Simulasi kebijakan refund',
            ),
            Text('Dihitung dari pengajuan hingga sesi dimulai.',
                style: jk(11, c: FC.muted)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sebelum kunjungan', style: jk(10.5, c: FC.muted)),
                  Text('Dana kembali', style: jk(10.5, c: FC.muted)),
                ],
              ),
            ),
            for (var i = 0; i < rows.length; i++)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: i == active ? FC.beige : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      i == active ? '${rows[i].$1} · Berlaku' : rows[i].$1,
                      style: jk(13,
                          w: i == active ? FontWeight.w800 : FontWeight.w400,
                          c: FC.dark),
                    ),
                    Text(rows[i].$2,
                        style: jk(14, w: FontWeight.w800, c: FC.dark)),
                  ],
                ),
              ),
            const FlowLine(),
            Text(
              rejected
                  ? 'Pengajuan: 23 Oktober 2026, 15.30 WIB'
                  : 'Pengajuan: 22 Oktober 2026, 15.30 WIB',
              style: jk(10.5, c: FC.muted),
            ),
            Text('Kunjungan: 24 Oktober 2026, 09.00 WIB',
                style: jk(10.5, c: FC.muted)),
          ],
        ),
        FlowCard(
          children: [
            Text('Rincian dana', style: jk(15, w: FontWeight.w800, c: FC.dark)),
            const SizedBox(height: 4),
            const KV('Total bayar · 2 tiket', 'Rp100.000', valueColor: FC.dark),
            KV(
              rejected ? 'Potongan · 100%' : 'Potongan · 25%',
              rejected ? '-Rp100.000' : '-Rp25.000',
              valueColor: FC.dark,
            ),
            const FlowLine(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Jumlah dikembalikan', style: jk(12, c: FC.muted)),
                Text(
                  rejected ? 'Rp0' : 'Rp75.000',
                  style: jk(17,
                      w: FontWeight.w800,
                      c: rejected ? FC.redDark : FC.dark),
                ),
              ],
            ),
          ],
        ),
        InfoBox(
          rejected
              ? 'Pengajuan 17 jam 30 menit sebelum kunjungan: dana kembali 0%. Refund tidak dapat diproses.'
              : 'Pengajuan 41 jam 30 menit sebelum kunjungan: dana kembali 75%.',
        ),
        if (rejected) ...[
          FlowButton(
            text: 'Kembali ke Tiket',
            onTap: () => backToTickets(context),
          ),
          FlowButton(
            text: 'Lihat Detail',
            outlinedRed: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RefundRejectedScreen()),
            ),
          ),
        ] else
          FlowButton(
            text: 'Lanjut',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RefundMethodScreen()),
            ),
          ),
        StepCard(
          label: 'Pengajuan refund',
          right: 'Langkah 2 dari 3',
          value: 0.67,
          color: rejected ? FC.redDark : FC.button,
          caption: rejected
              ? 'Pengajuan tidak memenuhi syarat refund.'
              : 'Cek kembali jumlah dana yang dikembalikan.',
        ),
      ],
    );
  }
}