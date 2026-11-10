import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Kartu yang bisa dibuka-tutup (judul + panah, isi muncul saat terbuka).
class AccordionCard extends StatelessWidget {
  const AccordionCard({
    super.key,
    required this.title,
    required this.open,
    required this.onTap,
    required this.body,
    this.expandedTitle,
    this.titleSize = 18,
    this.topPad = 11,
    this.gap = 17,
    this.bottomPad = 20,
  });

  final String title;
  final String? expandedTitle; // judul saat terbuka (kalau berbeda)
  final bool open;
  final VoidCallback onTap;
  final Widget body;
  final double titleSize;
  final double topPad; // jarak atas judul saat terbuka
  final double gap; // jarak judul ke isi
  final double bottomPad;

  TextStyle get _titleStyle => GoogleFonts.plusJakartaSans(
        fontSize: titleSize,
        fontWeight: FontWeight.w700,
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: open ? _buildExpanded() : _buildCollapsed(),
        ),
      ),
    );
  }

  Widget _buildCollapsed() {
    return Container(
      height: 51,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(child: Text(title, style: _titleStyle)),
          const Icon(Icons.keyboard_arrow_down, size: 28),
        ],
      ),
    );
  }

  Widget _buildExpanded() {
    return Padding(
      padding: EdgeInsets.fromLTRB(14, topPad, 14, bottomPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(expandedTitle ?? title, style: _titleStyle)),
              const Icon(Icons.keyboard_arrow_down, size: 28),
            ],
          ),
          SizedBox(height: gap),
          body,
        ],
      ),
    );
  }
}