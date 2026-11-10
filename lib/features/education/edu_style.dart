import 'package:flutter/material.dart';

class EduColors {
  static const olive = Color(0xFF7CAF4F);
  static const title = Color(0xFF2D4A1E);
  static const muted = Color(0xFF6B7F5A);
  static const red = Color(0xFFC8553D);
  static const gold = Color(0xFFD9A441);
  static const beige = Color(0xFFEFEBDD);
  static const quoteBg = Color(0xFFF0EDDD);
  static const done = Color(0xFF4A6B30);
  static const materi = Color(0xFF2E7D32);
}

/// Bar progres: [value] 0.0 - 1.0
class EduBar extends StatelessWidget {
  const EduBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 10,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        color: EduColors.beige,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value,
          child: Container(color: color),
        ),
      ),
    );
  }
}