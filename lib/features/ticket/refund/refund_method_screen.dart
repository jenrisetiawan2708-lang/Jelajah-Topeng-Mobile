import 'package:flutter/material.dart';
import '../flow_widgets.dart';
import 'refund_success_screen.dart';

class RefundMethodScreen extends StatefulWidget {
  const RefundMethodScreen({super.key});

  @override
  State<RefundMethodScreen> createState() => _RefundMethodScreenState();
}

class _RefundMethodScreenState extends State<RefundMethodScreen> {
  // (judul, keterangan, bank, rekening, atas nama)
  static const _methods = [
    ('Transfer Bank BCA', 'Rekening tersimpan', 'Bank BCA', '●●●● 4821', 'Anisa Putri'),
    ('Rekening bank lain', 'Tambahkan rekening tujuan', 'Bank lain', '—', '—'),
    ('Dompet digital', 'Pilih akun tujuan pengembalian', 'Dompet digital', '—', '—'),
  ];

  int _selected = 0;
  bool _agree = true;

  void _confirm() {
    final m = _methods[_selected];
    showDialog(
      context: context,
      barrierColor: const Color(0x992B3A22),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: FC.olive, width: 1.6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FlowTitle(label: 'PERIKSA PENGAJUAN', title: 'Konfirmasi Refund'),
              Text(
                'Ajukan pembatalan 2 tiket Kampung Budaya Polowijen untuk 24 Oktober 2026?',
                style: jk(12.5, h: 1.3),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dana dikembalikan', style: jk(12, c: FC.muted)),
                  Text('Rp75.000',
                      style: jk(16, w: FontWeight.w800, c: FC.dark)),
                ],
              ),
              const FlowLine(),
              KV('Metode', m.$1, valueColor: FC.dark),
              KV('Rekening', m.$4, valueColor: FC.dark),
              KV('Atas nama', m.$5, valueColor: FC.dark),
              const SizedBox(height: 8),
              const InfoBox('Tiket akan dibatalkan setelah pengajuan dikirim.'),
              const SizedBox(height: 12),
              FlowButton(
                text: 'Ya, Ajukan Refund',
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => RefundSuccessScreen(method: m.$1, account: m.$4, owner: m.$5),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              FlowButton(
                text: 'Batal',
                outlinedRed: true,
                onTap: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = _methods[_selected];
    return FlowScaffold(
      header: const FlowHeader(pill: 'Refund'),
      bottom: null,
      children: [
        const FlowCard(
          children: [
            FlowTitle(
              label: 'TUJUAN DANA REFUND',
              title: 'Metode Pengembalian',
              subtitle: 'Pilih tujuan pengembalian dana Rp75.000.',
            ),
          ],
        ),
        for (var i = 0; i < _methods.length; i++) _tile(i),
        FlowCard(
          children: [
            Text('Rekening tujuan terpilih',
                style: jk(14, w: FontWeight.w800, c: FC.dark)),
            const SizedBox(height: 4),
            KV(m.$3, m.$4, valueColor: FC.dark),
            KV('Pemilik rekening', m.$5, valueColor: FC.dark),
            const FlowLine(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dana dikembalikan', style: jk(12, c: FC.muted)),
                Text('Rp75.000',
                    style: jk(16, w: FontWeight.w800, c: FC.dark)),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => setState(() => _agree = !_agree),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _agree ? FC.button : Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: FC.button, width: 1.5),
                ),
                child: _agree
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Saya menyetujui simulasi kebijakan refund dan memastikan data rekening sudah benar.',
                  style: jk(11.5, c: FC.dark, h: 1.3),
                ),
              ),
            ],
          ),
        ),
        FlowButton(text: 'Tinjau Pengajuan', enabled: _agree, onTap: _confirm),
        const StepCard(
          label: 'Pengajuan refund',
          right: 'Langkah 3 dari 3',
          value: 1,
          caption: 'Pastikan rekening tujuan sudah benar.',
        ),
      ],
    );
  }

  Widget _tile(int i) {
    final sel = _selected == i;
    final m = _methods[i];
    return GestureDetector(
      onTap: () => setState(() => _selected = i),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: FC.olive, width: 1.6),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sel ? FC.button : FC.beige,
              ),
              child: Icon(
                sel ? Icons.check : Icons.account_balance,
                color: sel ? Colors.white : FC.muted,
                size: sel ? 26 : 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.$1, style: jk(14, w: FontWeight.w800, c: FC.dark)),
                  Text(sel ? '${m.$2} · Terpilih' : m.$2,
                      style: jk(11, c: FC.muted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: FC.muted, size: 26),
          ],
        ),
      ),
    );
  }
}