import 'booking/pick_date_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/accordion_card.dart';
import '../../shared/widgets/dark_button.dart';
import '../../shared/widgets/gradient_background.dart';
import '../education/edu_header.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  static const _packages = [
    (
      'Paket Sumbang Kampung',
      [
        'maks. 30 orang 1 Juta, selebihnya 25 rb/org',
        'Sinau Budaya adat dan Tradisi',
        'Sajian Tari Tradisi/Topeng',
        'Bebas Dokumentasi',
        'Demo membatik/topeng',
        'Kudapan jananan lawas',
        'Omben2 jamu / dawet',
        'Tambah makan sego berkat 20rb/org',
      ],
    ),
    (
      'Paket Sobo Pawon',
      [
        'Tiap orang 30 rb/orng',
        'Sedia busana tradisional',
        'Bebas dokumentasi',
        'Masak Cethik Geni Pawon',
        'Membatik/mewarnai Kerajinan',
        'Medayoh ke omah warga',
        'Omben2 kopi/rempah2',
        'Tambah Makan sego berkat 20 rb/org',
      ],
    ),
    (
      'Paket Medayoh',
      [
        'Khusus sabtu (13.00–17.00)',
        'Kelompok 3–10 org',
        'Tiap orang 30 rb',
        'Sinau Budaya & wawancara',
        'Bebas dokumentasi',
        'Sajian gladi Tari Topeng',
        'Ombeng2 dan jananan lawas',
        'Tambah makan sego berkat 20 rb/orng',
      ],
    ),
    (
      'Paket Selametan/Metri',
      [
        '1 jt untuk 20 org',
        'Cocok untuk mentri weton (ulang tahun kelahiran, pernikahan)',
        'Memakai busana adat',
        'Sego Tumpeng/sego berkat',
        'Jenang Sengkolo',
        'Jajanan lawas, Wedangan, Ngopi',
        'Bisa didekorasi, Bebas dokumentasi',
      ],
    ),
    (
      'Paket Hasta Karya',
      [
        'Memahat topeng 100 rb/org',
        'Membatik/ecoprint 50 rb/org',
        'Melukis topeng 25 rb/org',
        'Melukis jaranan 25 rb/org',
        'Melukis anyaman bambu 25 rb/org',
        'Melukis wayang 25 rb/org',
      ],
    ),
  ];

  int? _open; // paket yang sedang terbuka

  void _buy(String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PickDateScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            // Rumput + pohon: hanya tampil kalau semua kartu tertutup
            if (_open == null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Image.asset(
                  'assets/images/map_ground.png',
                  fit: BoxFit.fitWidth,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const EduHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 59, 20, 24),
                      child: Column(
                        children: [
                          for (var i = 0; i < _packages.length; i++)
                            _buildPackage(i),
                        ],
                      ),
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

  Widget _buildPackage(int i) {
    final title = _packages[i].$1;
    final isOpen = _open == i;
    return Column(
      children: [
        AccordionCard(
          title: title,
          titleSize: 20,
          topPad: 6,
          gap: 8,
          bottomPad: 16,
          open: isOpen,
          onTap: () => setState(() => _open = isOpen ? null : i),
          body: _buildList(_packages[i].$2),
        ),
        if (isOpen)
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: DarkButton(
                text: 'Beli',
                width: 82,
                height: 29,
                fontSize: 18,
                radius: 14,
                onPressed: () => _buy(title),
              ),
            ),
          ),
        const SizedBox(height: 14),
      ],
    );
  }

  // Daftar bernomor dengan indent menggantung
  Widget _buildList(List<String> items) {
    final style = GoogleFonts.plusJakartaSans(fontSize: 16, height: 1.25);
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 22, child: Text('${i + 1}.', style: style)),
                Expanded(child: Text(items[i], style: style)),
              ],
            ),
        ],
      ),
    );
  }
}