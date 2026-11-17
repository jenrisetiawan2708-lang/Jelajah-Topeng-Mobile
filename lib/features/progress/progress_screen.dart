import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({
    super.key,
    this.completed = 0,
    this.total = 6,
    this.showBack = true,
  });

  /// Jumlah tantangan yang sudah selesai.
  final int completed;

  /// Total tantangan di game.
  final int total;

  /// false jika dipakai sebagai tab (tidak perlu tombol kembali).
  final bool showBack;

  static const _board = <(String, int)>[
    ('Rangga', 120),
    ('Dewi', 95),
    ('Bayu', 80),
    ('Sari', 60),
  ];

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          'Progres Budaya',
          style: AppText.style(18, weight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tantangan selesai',
                  style: AppText.style(13, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  '$completed / $total',
                  style: AppText.style(
                    28,
                    weight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    color: AppColors.softGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Papan Peringkat',
            style: AppText.style(16, weight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < _board.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD5D9D0)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${i + 1}',
                      style: AppText.style(14, weight: FontWeight.w800),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _board[i].$1,
                      style: AppText.style(14, weight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${_board[i].$2} poin',
                    style: AppText.style(13, color: AppColors.muted),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
