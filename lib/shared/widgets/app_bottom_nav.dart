import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.home_rounded, 'Beranda'),
    (Icons.menu_book_outlined, 'Education'),
    (Icons.sports_esports_outlined, 'Game'),
    (Icons.confirmation_number_outlined, 'Ticket'),
    (Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < _items.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _items[i].$1,
                    size: 30,
                    color: i == currentIndex ? AppColors.primary : AppColors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _items[i].$2,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: i == currentIndex
                          ? AppColors.primary
                          : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}