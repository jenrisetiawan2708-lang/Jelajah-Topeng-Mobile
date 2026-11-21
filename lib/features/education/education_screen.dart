import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import 'edu_header.dart';
import 'edu_style.dart';
import '../exploration/exploration_screen.dart';
import 'education_data.dart';
import 'materi_screen.dart';

/// Daftar materi (tab Education).
class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  Future<void> _open(Materi m) async {
    await Navigator.of(context).push(eduFade(MateriScreen(materi: m)));
    if (mounted) setState(() {});
  }

  void _openExploration() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ExplorationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EduColors.bgTop,
      body: EduBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EduBackBtn(),
                    const SizedBox(width: 10),
                    EduMapBtn(onTap: _openExploration),
                    const Spacer(),
                    const EduGemBadge(),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                  itemCount: materiList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (_, i) {
                    final m = materiList[i];
                    return GestureDetector(
                      onTap: () => _open(m),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 16, 18, 16),
                        decoration: eduCardDeco(
                          radius: 24,
                          border: 1.4,
                          borderColor: EduColors.listBorder,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MATERI ${m.number}',
                                    style: AppText.style(
                                      17,
                                      weight: FontWeight.w800,
                                      color: EduColors.listGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    m.title,
                                    style: AppText.style(
                                      17,
                                      weight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${m.author} - ${m.readings.length} Sub Bab',
                                    style: AppText.style(
                                      15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 32,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
