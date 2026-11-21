import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import 'edu_header.dart';
import 'edu_style.dart';
import 'education_data.dart';

/// Halaman baca. Teks bisa digulir, kutipan krem tetap di bawah kartu.
class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key, required this.materi, required this.index});
  final Materi materi;
  final int index;

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  @override
  void initState() {
    super.initState();
    // Begitu dibuka, bacaan yang belum dimulai menjadi "sedang dibaca".
    if (EducationProgress.of(widget.materi.number, widget.index) == 0) {
      EducationProgress.set(widget.materi.number, widget.index, 1);
    }
  }

  void _next() {
    final m = widget.materi;
    EducationProgress.set(m.number, widget.index, 2);
    if (widget.index + 1 < m.readings.length) {
      Navigator.of(context).pushReplacement(
        eduFade(ReadingScreen(materi: m, index: widget.index + 1)),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.materi;
    final r = m.readings[widget.index];
    final status = EducationProgress.of(m.number, widget.index);
    final longQuote = r.quote.length > 60;

    return Scaffold(
      backgroundColor: EduColors.bgTop,
      body: EduBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const EduBackBtn(),
                    const Spacer(),
                    EduNextBtn(onTap: _next),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                    decoration: eduCardDeco(radius: 28, border: 2.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.eyebrow,
                          style: AppText.style(
                            14,
                            weight: FontWeight.w700,
                            color: EduColors.red,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          r.heading,
                          style: AppText.style(
                            34,
                            weight: FontWeight.w800,
                            color: EduColors.forest,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bacaan · Teks ilustratif',
                          style: AppText.style(12, color: EduColors.grey),
                        ),
                        const SizedBox(height: 10),
                        Container(height: 2, color: EduColors.beige),
                        const SizedBox(height: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (
                                  var i = 0;
                                  i < r.paragraphs.length;
                                  i++
                                ) ...[
                                  Text(
                                    r.paragraphs[i],
                                    style: AppText.style(
                                      14,
                                      color: EduColors.text,
                                      height: 1.6,
                                    ),
                                  ),
                                  if (i < r.paragraphs.length - 1)
                                    const SizedBox(height: 16),
                                ],
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                          decoration: BoxDecoration(
                            color: EduColors.beige,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.format_quote_rounded,
                                size: 24,
                                color: EduColors.gold,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  r.quote,
                                  style: AppText.style(
                                    longQuote ? 13 : 18,
                                    weight: FontWeight.w800,
                                    color: EduColors.forest,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ReadStatusCard(status: status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadStatusCard extends StatelessWidget {
  const _ReadStatusCard({required this.status});
  final int status;

  @override
  Widget build(BuildContext context) {
    final String label;
    final String caption;
    final Color color;
    final double value;

    if (status == 2) {
      label = 'Selesai dibaca';
      caption = 'Hebat! Nilai Budaya sudah kamu baca.';
      color = EduColors.forestDark;
      value = 1;
    } else if (status == 1) {
      label = 'Sedang dibaca';
      caption = 'Teruskan bacaan Nilai Budaya, yuk!';
      color = EduColors.gold;
      value = 0.5;
    } else {
      label = 'Belum dimulai';
      caption = 'Yuk, kenali nilai budaya di sekitar kita.';
      color = EduColors.beige;
      value = 0;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: eduShadow(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bacaan ini',
                style: AppText.style(12, color: EduColors.grey),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status == 2)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: EduColors.forestDark,
                      ),
                    ),
                  Text(
                    label,
                    style: AppText.style(
                      15,
                      weight: FontWeight.w800,
                      color: EduColors.forest,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          EduProgressBar(value: value, color: color),
          const SizedBox(height: 8),
          Text(caption, style: AppText.style(11, color: EduColors.greyLight)),
        ],
      ),
    );
  }
}
