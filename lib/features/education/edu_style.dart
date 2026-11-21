import 'package:flutter/material.dart';

/// Warna halaman Education (diambil dari wireframe high-fi).
class EduColors {
  static const bgTop = Color(0xFFD2EEA4);
  static const bgMid = Color(0xFFFBFDF8);
  static const bgBottom = Color(0xFFE0F5C0);

  static const forest = Color(0xFF2E4A21); // judul besar
  static const forestDark = Color(0xFF4C6B33); // centang selesai
  static const border = Color(0xFF7FAE55); // garis kartu detail
  static const listGreen = Color(0xFF2E7D32); // "MATERI 1" di daftar
  static const listBorder = Color(0xFF4CAF50); // garis kartu daftar
  static const gold = Color(0xFFD9A441);
  static const gem = Color(0xFFF7CF68);
  static const red = Color(0xFFC4573F);
  static const grey = Color(0xFF6B7A5C);
  static const greyLight = Color(0xFF909B85);
  static const text = Color(0xFF1F2A17);
  static const beige = Color(0xFFF1EEDD); // kotak kutipan, track, nomor
}

List<BoxShadow> eduShadow([double alpha = 0.08]) => [
  BoxShadow(
    color: Colors.black.withValues(alpha: alpha),
    blurRadius: 14,
    offset: const Offset(0, 4),
  ),
];

/// Kartu putih dengan garis hijau.
BoxDecoration eduCardDeco({
  double radius = 24,
  double border = 2,
  Color borderColor = EduColors.border,
}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor, width: border),
    boxShadow: eduShadow(),
  );
}

Route<T> eduFade<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, _, child) =>
        FadeTransition(opacity: a, child: child),
  );
}

class EduProgressBar extends StatelessWidget {
  const EduProgressBar({super.key, required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 9,
        backgroundColor: EduColors.beige,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}
