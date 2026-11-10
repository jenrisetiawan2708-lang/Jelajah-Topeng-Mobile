import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/accordion_card.dart';
import '../../shared/widgets/gradient_background.dart';
import '../game/game_header.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // (judul, isi, judul saat terbuka)
  static const _items = [
    (
      'Sesi Booking dikonfirmasi',
      'Sesi Bersama Ki Sujono Berhasil di konfirmasi untuk Sabtu, 12 Desember 2028',
      null,
    ),
    (
      'Tiket Kunjungan aktif',
      'Tiket Paket Maestro untuk 2 orang sudah bisa digunakan di lokasi.',
      'Tiket Kunjungan Aktif',
    ),
    (
      'Informasi Perbaikan',
      'Untuk Kunjungan Makam Mbah Reni untuk saat ini masih dalam Tahap Maintanance',
      null,
    ),
  ];

  int? _open; // kartu yang sedang terbuka

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const GameHeader(title: 'Notifikasi', score: 5),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 59, 20, 24),
                  child: Column(
                    children: [
                      for (var i = 0; i < _items.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: AccordionCard(
                            title: _items[i].$1,
                            expandedTitle: _items[i].$3,
                            open: _open == i,
                            onTap: () =>
                                setState(() => _open = _open == i ? null : i),
                            body: Text(
                              _items[i].$2,
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
            ],
          ),
        ),
      ),
    );
  }
}