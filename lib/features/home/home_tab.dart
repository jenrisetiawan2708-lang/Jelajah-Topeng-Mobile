import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../auth/auth_service.dart';
import '../exploration/exploration_screen.dart';
import '../ticket/booking/package_select_screen.dart';

/// Beranda (V2)
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  static const _heroAsset = 'assets/images/home_hero.png';
  static const _activityAsset = 'assets/images/activity_tari.png';

  static const _activities = [
    ('Latihan Tari Topeng: Gerakan Dasar', '24 Oktober 2026, pukul 14.00 WIB'),
    ('Latihan Tari Topeng: Gerakan Dasar', '31 Oktober 2026, pukul 14.00 WIB'),
  ];

  /// Nama depan user yang login, cadangannya "Sobat".
  String get _firstName {
    final full = AuthService.current?.name.trim() ?? '';
    if (full.isEmpty) return 'Sobat';
    return full.split(RegExp(r'\s+')).first;
  }

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
            _Header(name: _firstName),
            const SizedBox(height: 18),
            const _MapCard(asset: _heroAsset),
            const SizedBox(height: 12),
            const _EventCard(),
            const SizedBox(height: 24),
            Text(
              'Aktivitas',
              style: AppText.style(18, weight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final a in _activities) ...[
              _ActivityItem(title: a.$1, time: a.$2, asset: _activityAsset),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gambar PNG yang pinggirannya transparan dipotong otomatis, lalu diisikan
// penuh (cover) ke kotaknya. Hasil dipakai ulang (cache).
// ---------------------------------------------------------------------------
class _Trimmed {
  const _Trimmed(this.image, this.bounds);
  final ui.Image image;
  final Rect bounds;
}

final Map<String, Future<_Trimmed>> _trimCache = {};

Future<_Trimmed> _loadTrimmed(String asset) {
  return _trimCache.putIfAbsent(asset, () async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final img = frame.image;
    final bytes = await img.toByteData(format: ui.ImageByteFormat.rawRgba);

    var bounds = Rect.fromLTWH(
      0,
      0,
      img.width.toDouble(),
      img.height.toDouble(),
    );
    if (bytes != null) {
      final w = img.width;
      final h = img.height;
      var minX = w;
      var minY = h;
      var maxX = -1;
      var maxY = -1;
      for (var y = 0; y < h; y++) {
        final row = y * w * 4;
        for (var x = 0; x < w; x++) {
          // Hanya piksel yang hampir solid; bayangan lembut diabaikan.
          if (bytes.getUint8(row + x * 4 + 3) > 230) {
            if (x < minX) minX = x;
            if (x > maxX) maxX = x;
            if (y < minY) minY = y;
            maxY = y;
          }
        }
      }
      if (maxX >= minX && maxY >= minY) {
        bounds = Rect.fromLTRB(
          minX.toDouble(),
          minY.toDouble(),
          (maxX + 1).toDouble(),
          (maxY + 1).toDouble(),
        );
      }
    }
    return _Trimmed(img, bounds);
  });
}

class _TrimmedImage extends StatelessWidget {
  const _TrimmedImage({
    required this.asset,
    this.alignment = Alignment.center,
    this.inset = 0.02,
    this.fallback,
  });

  final String asset;
  final Alignment alignment;

  /// Potongan tambahan (pecahan sisi terpendek) untuk membuang sudut bulat.
  final double inset;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Trimmed>(
      future: _loadTrimmed(asset),
      builder: (_, snap) {
        if (snap.hasError) return fallback ?? const SizedBox.shrink();
        final t = snap.data;
        if (t == null) return const SizedBox.shrink();
        return SizedBox.expand(
          child: CustomPaint(painter: _TrimPainter(t, alignment, inset)),
        );
      },
    );
  }
}

class _TrimPainter extends CustomPainter {
  _TrimPainter(this.t, this.alignment, this.inset);
  final _Trimmed t;
  final Alignment alignment;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final cut = math.min(t.bounds.width, t.bounds.height) * inset;
    final src = t.bounds.deflate(cut);
    final scale = math.max(size.width / src.width, size.height / src.height);
    final w = size.width / scale;
    final h = size.height / scale;
    final left = src.left + (src.width - w) * (alignment.x + 1) / 2;
    final top = src.top + (src.height - h) * (alignment.y + 1) / 2;
    canvas.drawImageRect(
      t.image,
      Rect.fromLTWH(left, top, w, h),
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(covariant _TrimPainter old) =>
      old.t != t || old.alignment != alignment || old.inset != inset;
}

// ---------------------------------------------------------------------------
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
  const _MapCard({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ExplorationScreen())),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.forest.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: AppColors.forest),
              _TrimmedImage(
                asset: asset,
                alignment: Alignment.topCenter,
                inset: 0.02,
                fallback: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.forest],
                    ),
                  ),
                ),
              ),
              // Gradasi gelap hanya di bagian bawah supaya teks terbaca.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
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
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jelajahi Kampung Polowijen',
                      style: AppText.style(
                        17,
                        weight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Buka peta dan temukan 5 lokasi bersejarah',
                      style: AppText.style(
                        12,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
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
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PackageSelectScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.title,
    required this.time,
    required this.asset,
  });
  final String title;
  final String time;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 64,
              height: 64,
              child: _TrimmedImage(
                asset: asset,
                inset: 0.07,
                fallback: const ColoredBox(
                  color: AppColors.lime,
                  child: Icon(
                    Icons.theater_comedy_rounded,
                    color: AppColors.forest,
                  ),
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
                Text(time, style: AppText.style(12, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
