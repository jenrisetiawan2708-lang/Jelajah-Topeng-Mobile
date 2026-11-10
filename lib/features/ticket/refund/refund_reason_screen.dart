import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../flow_widgets.dart';
import 'refund_policy_screen.dart';

class RefundReasonScreen extends StatefulWidget {
  const RefundReasonScreen({super.key});

  @override
  State<RefundReasonScreen> createState() => _RefundReasonScreenState();
}

class _RefundReasonScreenState extends State<RefundReasonScreen> {
  static const _reasons = [
    'Perubahan jadwal perjalanan',
    'Berhalangan Hadir',
    'Pemesanan tidak sesuai',
    'Alasan lainnya',
  ];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      header: const FlowHeader(pill: 'Refund'),
      children: [
        const FlowCard(
          children: [
            FlowTitle(
              label: 'PENGAJUAN REFUND',
              title: 'Alasan Pembatalan',
              subtitle: 'Bantu kami memahami perubahan rencanamu.',
            ),
          ],
        ),
        FlowCard(
          children: [
            Text('Kampung Budaya Polowijen',
                style: jk(16, w: FontWeight.w800, c: FC.dark)),
            const SizedBox(height: 2),
            Text('KBP-241026-018 · 2 tiket', style: jk(11.5, c: FC.muted)),
            const SizedBox(height: 4),
            Text('24 Oktober 2026 · 09.00–11.00 WIB',
                style: jk(12, c: const Color(0xFF444444))),
          ],
        ),
        Text('Mengapa ingin membatalkan?',
            style: jk(15, w: FontWeight.w800, c: FC.dark)),
        for (var i = 0; i < _reasons.length; i++) _radio(i),
        FlowCard(
          children: [
            Text('Catatan tambahan (opsional)',
                style: jk(13, w: FontWeight.w800, c: FC.dark)),
            TextField(
              maxLines: 3,
              style: jk(12),
              decoration: InputDecoration(
                hintText: 'Tuliskan informasi tambahan di sini...',
                hintStyle: jk(11.5, c: FC.muted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.only(top: 6),
              ),
            ),
          ],
        ),
        FlowButton(
          text: 'Lanjut',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              // "Berhalangan Hadir" -> skenario <24 jam (ditolak) untuk demo
              builder: (_) => RefundPolicyScreen(rejected: _selected == 1),
            ),
          ),
        ),
        const StepCard(
          label: 'Pengajuan refund',
          right: 'Langkah 1 dari 3',
          value: 0.33,
          caption: 'Pilih alasan yang paling sesuai.',
        ),
      ],
    );
  }

  Widget _radio(int i) {
    final sel = _selected == i;
    return GestureDetector(
      onTap: () => setState(() => _selected = i),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 1.4),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: FC.dark, width: 1.5),
              ),
              child: sel
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: FC.dark,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(_reasons[i],
                style: jk(13, w: sel ? FontWeight.w800 : FontWeight.w400, c: FC.dark)),
          ],
        ),
      ),
    );
  }
}