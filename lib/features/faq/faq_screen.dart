import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _items = <(String, String)>[
    (
      'Apa itu Jelajah Topeng?',
      'Aplikasi untuk menjelajahi Kampung Budaya Polowijen, belajar '
          'tentang Topeng Malangan, dan bermain game jejak budaya.',
    ),
    (
      'Bagaimana cara membeli tiket?',
      'Buka tab Tiket, pilih paket, isi data, lalu selesaikan pembayaran.',
    ),
    (
      'Apakah bisa refund tiket?',
      'Bisa, melalui menu Riwayat Pesanan sesuai ketentuan refund yang berlaku.',
    ),
    (
      'Bagaimana cara bermain game Jejak Sang Panji?',
      'Buka tab Game, ikuti titik pada peta, lalu selesaikan tantangan '
          'di setiap lokasi untuk mengumpulkan clue.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text('FAQ', style: AppText.style(18, weight: FontWeight.w800)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final (q, a) = _items[i];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD5D9D0)),
            ),
            child: Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                iconColor: AppColors.primary,
                collapsedIconColor: AppColors.muted,
                title: Text(
                  q,
                  style: AppText.style(14, weight: FontWeight.w700),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(a, style: AppText.style(13, height: 1.4)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
