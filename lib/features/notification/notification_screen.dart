import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api/api_client.dart';
import '../../core/api/content_service.dart';
import '../../shared/widgets/accordion_card.dart';
import '../../shared/widgets/gradient_background.dart';
import '../education/edu_header.dart';

class _Notif {
  const _Notif(this.title, this.body, [this.expandedTitle]);
  final String title;
  final String body;
  final String? expandedTitle;
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Bawaan aplikasi. Item dari web admin hanya TAMBAHAN (nama sama dilewati).
  static const _local = [
    _Notif(
      'Sesi Booking dikonfirmasi',
      'Sesi Bersama Ki Sujono Berhasil di konfirmasi untuk Sabtu, 12 Desember 2028',
    ),
    _Notif(
      'Tiket Kunjungan aktif',
      'Tiket Paket Maestro untuk 2 orang sudah bisa digunakan di lokasi.',
      'Tiket Kunjungan Aktif',
    ),
    _Notif(
      'Informasi Perbaikan',
      'Untuk Kunjungan Makam Mbah Reni untuk saat ini masih dalam Tahap Maintanance',
    ),
  ];

  List<_Notif> _remote = const [];
  bool _loading = true;
  String? _error;
  int? _open;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ContentService.kind('notification');
      final extra = ContentService.extras(items, _local.map((e) => e.title));
      if (!mounted) return;
      setState(() {
        _remote = [for (final i in extra) _Notif(i.name, i.description)];
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat notifikasi.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Terbaru dari web admin di atas, lalu notifikasi bawaan.
    final all = [..._remote, ..._local];

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    const EduBackBtn(),
                    Expanded(
                      child: Text(
                        'Notifikasi',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const EduGemBadge(),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                    child: Column(
                      children: [
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 18),
                            child: LinearProgressIndicator(minHeight: 3),
                          ),
                        if (_error != null) _errorBox(),
                        for (var i = 0; i < all.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: AccordionCard(
                              title: all[i].title,
                              expandedTitle: all[i].expandedTitle,
                              open: _open == i,
                              onTap: () =>
                                  setState(() => _open = _open == i ? null : i),
                              body: Text(
                                all[i].body,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE9E7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$_error',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFFB3261E),
              ),
            ),
          ),
          TextButton(onPressed: _load, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
