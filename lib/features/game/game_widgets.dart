import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warna khusus layar game, diambil dari desain.
class GameColors {
  static const skyTop = Color(0xFFD2EEA8);
  static const mintBottom = Color(0xFFE6F5D8);
  static const green = Color(0xFF66A03A);
  static const greenLine = Color(0xFF4CAF50);
  static const forestDark = Color(0xFF1F3A14);
  static const forestLight = Color(0xFF3E7230);
  static const lockTop = Color(0xFFBDBDBD);
  static const lockSide = Color(0xFF909090);
  static const lockIcon = Color(0xFF7D7878);
  static const wrong = Color(0xFFFF0000);
  static const wrongBg = Color(0xFFFAE6E3);
  static const wrongBar = Color(0xFFD9382F);
  static const wrongText = Color(0xFFB3261E);
}

TextStyle gameText(
  double size, {
  FontWeight weight = FontWeight.w500,
  Color color = Colors.black,
  double? height,
}) => GoogleFonts.plusJakartaSans(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
);

/// Latar hijau muda di atas, memudar ke putih lalu mint di bawah.
class GameBackground extends StatelessWidget {
  const GameBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GameColors.skyTop, Colors.white, GameColors.mintBottom],
          stops: [0.0, 0.42, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// Baris atas: tombol kembali, judul, dan penghitung permata.
class GameHeader extends StatelessWidget {
  const GameHeader({super.key, required this.title, required this.gems});
  final String title;
  final int gems;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.chevron_left_rounded, size: 34),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: gameText(19, weight: FontWeight.w800),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.diamond_rounded,
                  color: Color(0xFFFFC94D),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text('$gems/5', style: gameText(18, weight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Panel hijau tua dengan "bibir" hijau terang di bawahnya (efek 3D).
class GameDarkPanel extends StatelessWidget {
  const GameDarkPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 28,
  });
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: GameColors.green,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 22,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [GameColors.forestDark, GameColors.forestLight],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Tombol hijau tua bergaya 3D.
class GameButton extends StatelessWidget {
  const GameButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
  });
  final String text;
  final VoidCallback? onPressed;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: GestureDetector(
        onTap: onPressed,
        child: SizedBox(
          width: width,
          child: GameDarkPanel(
            radius: 30,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Text(
                text,
                style: gameText(
                  18,
                  weight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
