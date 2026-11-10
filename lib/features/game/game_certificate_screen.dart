import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../shared/widgets/asset_icon.dart';
import '../../shared/widgets/gradient_background.dart';
import 'game_header.dart';

class GameCertificateScreen extends StatelessWidget {
  const GameCertificateScreen({super.key});

  static const _name = 'Rangga Pratama';
  static const _date = '4 September 2026';
  static const _number = 'JTP-0923-041';
  static const _fileName = 'Sertifikat_Jejak_Sang_Panji.pdf';

  static const _dark = Color(0xFF1E2F13);
  static const _muted = Color(0xFF6B7F5A);

  // Membuat file PDF sertifikat
  static Future<Uint8List> _buildPdf() async {
    final doc = pw.Document();
    const dark = PdfColor.fromInt(0xFF1E2F13);
    const green = PdfColor.fromInt(0xFF4CAF50);
    final format = PdfPageFormat.a4.landscape;

    pw.Widget line(String text, double size, {bool bold = false}) {
      return pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: size,
          color: dark,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      );
    }

    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => pw.Container(
          width: format.width - 56,
          height: format.height - 56,
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: green, width: 4),
          ),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              line('SERTIFIKAT', 44, bold: true),
              pw.SizedBox(height: 6),
              line('Game Jejak Sang Panji', 20),
              pw.SizedBox(height: 32),
              line('Diberikan kepada', 16),
              pw.SizedBox(height: 8),
              line(_name, 34, bold: true),
              pw.SizedBox(height: 20),
              line('Berhasil menyelesaikan seluruh pemberhentian', 16),
              line('dan menemukan Dewi Sekartaji.', 16),
              pw.SizedBox(height: 32),
              line('Diterbitkan: $_date', 13),
              pw.SizedBox(height: 4),
              line('Nomor Sertifikat: $_number', 13, bold: true),
            ],
          ),
        ),
      ),
    );
    return doc.save();
  }

  // Unduh: buka share sheet (simpan ke File / Drive / kirim)
  static Future<void> _download() async {
    final bytes = await _buildPdf();
    try {
      await Printing.sharePdf(bytes: bytes, filename: _fileName);
    } catch (_) {
      // cadangan: dialog cetak / simpan sebagai PDF
      await Printing.layoutPdf(onLayout: (_) async => bytes, name: _fileName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const GameHeader(title: 'Sertifikat', score: 5),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sertifikat 1',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildCard(),
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

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7CAF4F), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD7A83F),
                ),
                child: const Center(
                  child: AssetIcon(
                    path: 'assets/images/ic_medal.png',
                    fallback: Icons.military_tech,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Game Jejak Sang Panji',
                      style: GoogleFonts.plusJakartaSans(
                        color: _dark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Berhasil menyelesaikan seluruh pemberhentian',
                      style: GoogleFonts.plusJakartaSans(
                        color: _muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _DashedLine(),
          const SizedBox(height: 12),
          _row('Penerima', _name),
          _row('Diterbitkan', _date),
          _row('Nomor Sertifikat', _number),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _download,
            child: Container(
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF2F4A20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Unduh PDF',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(color: _muted, fontSize: 13),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: _dark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// Garis putus-putus pemisah di dalam kartu
class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final count = (c.maxWidth / 9).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => const SizedBox(
              width: 5,
              height: 1.5,
              child: ColoredBox(color: Color(0xFFDDE5C8)),
            ),
          ),
        );
      },
    );
  }
}