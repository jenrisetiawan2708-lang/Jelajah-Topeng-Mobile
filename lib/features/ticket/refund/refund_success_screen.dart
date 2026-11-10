import 'package:flutter/material.dart';
import '../flow_widgets.dart';
import 'refund_status_screen.dart';

class RefundSuccessScreen extends StatelessWidget {
  const RefundSuccessScreen({
    super.key,
    this.method = 'Transfer Bank BCA',
    this.account = '●●●● 4821',
    this.owner = 'Anisa Putri',
  });

  final String method;
  final String account;
  final String owner;

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      header: const FlowHeader(pill: 'Tiket saya'),
      children: [
        FlowCard(
          children: [
            const FlowTitle(label: 'PENGAJUAN DITERIMA', title: 'Pengajuan Berhasil'),
            const SizedBox(height: 4),
            Center(
              child: Container(
                padding: const EdgeInsets.only(bottom: 4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6AA83A),
                ),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: FC.button,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 66),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pengajuan refund tiketmu berhasil dikirim. Kami akan memeriksa dan memproses pengembalian dananya.',
              textAlign: TextAlign.center,
              style: jk(11.5, h: 1.35),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: FC.beige,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text('Nomor pengajuan refund', style: jk(10.5, c: FC.muted)),
                  Text('RF-221026-018',
                      style: jk(19, w: FontWeight.w800, c: FC.dark)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text('22 Oktober 2026 · 15.30 WIB',
                  style: jk(10, c: FC.muted)),
            ),
            const FlowLine(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dana dikembalikan', style: jk(12, c: FC.muted)),
                Text('Rp75.000',
                    style: jk(16, w: FontWeight.w800, c: FC.dark)),
              ],
            ),
            KV(method, account, valueColor: FC.dark, labelSize: 11),
            Text('Atas nama $owner', style: jk(11, c: FC.muted)),
          ],
        ),
        const InfoBox('Pantau perkembangannya melalui halaman Status Refund.'),
        FlowButton(
          text: 'Lihat Status Refund',
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const RefundStatusScreen()),
          ),
        ),
        const StepCard(
          label: 'Status pengajuan',
          right: 'Berhasil diajukan',
          value: 1,
          caption: 'Terima kasih. Pengajuanmu sudah kami terima.',
        ),
      ],
    );
  }
}