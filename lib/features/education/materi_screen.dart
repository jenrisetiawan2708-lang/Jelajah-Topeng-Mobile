import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import 'edu_header.dart';
import 'edu_style.dart';
import 'education_data.dart';
import 'reading_screen.dart';

/// Detail materi: judul, tentang, daftar bacaan, progres.
class MateriScreen extends StatefulWidget {
  const MateriScreen({super.key, required this.materi});
  final Materi materi;

  @override
  State<MateriScreen> createState() => _MateriScreenState();
}

class _MateriScreenState extends State<MateriScreen> {
  Future<void> _openReading(int index) async {
    await Navigator.of(context)
        .push(eduFade(ReadingScreen(materi: widget.materi, index: index)));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.materi;
    final total = m.readings.length;
    final done = EducationProgress.doneCount(m);
    final reading = EducationProgress.readingCount(m);
    // Selesai = 1 poin, sedang dibaca = setengah poin.
    final progress = total == 0 ? 0.0 : (done + reading * 0.5) / total;
    final pct = (progress * 100).round();

    return Scaffold(
      backgroundColor: EduColors.bgTop,
      body: EduBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            children: [
              const Row(children: [EduBackBtn(), Spacer(), EduGemBadge()]),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                decoration: eduCardDeco(radius: 24, border: 2.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MATERI ${m.number}',
                      style: AppText.style(
                        14,
                        weight: FontWeight.w700,
                        color: EduColors.red,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      m.title.toUpperCase(),
                      style: AppText.style(
                        24,
                        weight: FontWeight.w800,
                        color: EduColors.forest,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'oleh ${m.author}',
                      style: AppText.style(14, color: EduColors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tentang Materi',
                style: AppText.style(
                  21,
                  weight: FontWeight.w800,
                  color: EduColors.forest,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                m.about,
                style: AppText.style(15, color: EduColors.text, height: 1.65),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Pelajari Materi',
                    style: AppText.style(
                      21,
                      weight: FontWeight.w800,
                      color: EduColors.forest,
                    ),
                  ),
                  Text(
                    '$total Bacaan',
                    style: AppText.style(
                      14,
                      weight: FontWeight.w600,
                      color: EduColors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < total; i++) ...[
                _ReadingTile(
                  title: m.readings[i].title,
                  number: i + 1,
                  status: EducationProgress.of(m.number, i),
                  onTap: () => _openReading(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                decoration: eduCardDeco(radius: 26, border: 2.5),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress Belajar · $pct%',
                          style: AppText.style(
                            14,
                            weight: FontWeight.w800,
                            color: EduColors.forest,
                          ),
                        ),
                        Text(
                          '$done dari $total materi selesai',
                          style: AppText.style(
                            12,
                            weight: FontWeight.w600,
                            color: EduColors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, _) =>
                          EduProgressBar(value: v, color: EduColors.gold),
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

class _ReadingTile extends StatelessWidget {
  const _ReadingTile({
    required this.title,
    required this.number,
    required this.status,
    required this.onTap,
  });
  final String title;
  final int number;
  final int status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget badge;
    if (status == 2) {
      badge = _circle(
        EduColors.forestDark,
        const Icon(Icons.check_rounded, size: 22, color: Colors.white),
      );
    } else if (status == 1) {
      badge = _circle(
        EduColors.gold,
        const Icon(Icons.check_rounded, size: 22, color: EduColors.text),
      );
    } else {
      badge = _circle(
        EduColors.beige,
        Text(
          '$number',
          style: AppText.style(
            15,
            weight: FontWeight.w800,
            color: EduColors.grey,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: eduCardDeco(radius: 26, border: 2),
        child: Row(
          children: [
            badge,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.style(
                      15,
                      weight: FontWeight.w600,
                      color: EduColors.forest,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Bacaan',
                    style: AppText.style(13, color: EduColors.grey),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 28,
              color: EduColors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(Color color, Widget child) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }
}
