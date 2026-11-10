import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text.dart';

/// Beranda (V2)
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  static const _activities = [
    ('Latihan Tari Topeng: Gerakan Dasar', '24 Oktober 2026, pukul 14.00 WIB'),
    ('Latihan Tari Topeng: Gerakan Dasar', '31 Oktober 2026, pukul 14.00 WIB'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.mintTop, AppColors.mintBottom],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 160),
          children: [
            const _Header(name: 'Rangga'),
            const SizedBox(height: 16),
            const _MapCard(),
            const SizedBox(height: 12),
            const _EventCard(),
            const SizedBox(height: 22),
            Text(
              'Aktivitas',
              style: AppText.style(18, weight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final a in _activities) ...[
              _ActivityItem(title: a.$1, time: a.$2),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.softGreen,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.person_rounded, color: AppColors.forest),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey, $name!',
                style: AppText.style(20, weight: FontWeight.w800),
              ),
              Text(
                'Selamat Datang',
                style: AppText.style(13, color: AppColors.muted),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.ink,
              ),
            ),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE53935),
                ),
                child: Text(
                  '3',
                  style: AppText.style(
                    10,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 170,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Taruh foto di assets/images/polowijen_hero.jpg
            Image.asset(
              'assets/images/polowijen_hero.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.forest],
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Buka Peta',
                  style: AppText.style(
                    12,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jelajahi Kampung Polowijen',
                    style: AppText.style(
                      16,
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Buka peta dan temukan 5 lokasi bersejarah',
                    style: AppText.style(
                      12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pertunjukan Malam Maestro',
                  style: AppText.style(
                    16,
                    weight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sab, 24 Okt 2026 · 13.00 - 17.00',
                  style: AppText.style(
                    12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.softGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Pesan Tiket',
              style: AppText.style(
                12,
                weight: FontWeight.w800,
                color: AppColors.forest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.title, required this.time});
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 60,
            height: 60,
            // Taruh foto di assets/images/activity_tari.jpg
            child: Image.asset(
              'assets/images/activity_tari.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: AppColors.lime,
                child: Icon(Icons.theater_comedy_rounded,
                    color: AppColors.forest),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.style(14, weight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                time,
                style: AppText.style(12, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}