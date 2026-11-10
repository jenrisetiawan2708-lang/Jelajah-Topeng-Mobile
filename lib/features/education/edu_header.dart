import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/asset_icon.dart';

/// Header Education: tombol back + (opsional) tombol peta + skor atau tombol Next.
class EduHeader extends StatelessWidget {
  const EduHeader({
    super.key,
    this.showMap = false,
    this.onNext,
    this.onMap,
  });

  final bool showMap;
  final VoidCallback? onNext; // kalau diisi, kanan atas jadi tombol "Next"
  final VoidCallback? onMap; // aksi tombol peta

  BoxDecoration get _pillDecoration => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(26),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 53,
              height: 53,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              child: const Icon(Icons.chevron_left, size: 36, color: Colors.black),
            ),
          ),
          if (showMap) ...[
            const SizedBox(width: 6),
            GestureDetector(onTap: onMap, child: _buildMapButton()),
          ],
          const Spacer(),
          onNext != null ? _buildNext() : _buildScore(),
        ],
      ),
    );
  }

  Widget _buildMapButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Container(
            width: 52,
            height: 43,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                colors: [AppColors.darkGreen, AppColors.midGreen],
              ),
            ),
            child: const Icon(Icons.map, color: Colors.white, size: 26),
          ),
        ),
        Positioned(
          top: -12,
          right: -4,
          child: Text(
            '1',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScore() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: _pillDecoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AssetIcon(
            path: 'assets/images/ic_diamond.png',
            fallback: Icons.diamond,
            size: 30,
            color: Color(0xFFF7C95C),
          ),
          const SizedBox(width: 8),
          Text(
            '5/5',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNext() {
    return GestureDetector(
      onTap: onNext,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        alignment: Alignment.center,
        decoration: _pillDecoration,
        child: Text(
          'Next',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}