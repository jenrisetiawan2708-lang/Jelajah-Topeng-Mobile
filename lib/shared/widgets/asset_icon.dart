import 'package:flutter/material.dart';

class AssetIcon extends StatelessWidget {
  const AssetIcon({
    super.key,
    required this.path,
    required this.fallback,
    this.size = 28,
    this.color,
  });

  final String path;
  final IconData fallback;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(fallback, size: size, color: color),
    );
  }
}