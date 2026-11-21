import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_text.dart';
import 'edu_style.dart';

/// Latar gradasi hijau muda -> putih -> hijau muda.
class EduBackground extends StatelessWidget {
  const EduBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [EduColors.bgTop, EduColors.bgMid, EduColors.bgBottom],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Dekorasi tombol "kaca" di bagian atas (back, 5/5, Next).
BoxDecoration eduGlassDeco({BoxShape shape = BoxShape.circle}) {
  return BoxDecoration(
    shape: shape,
    borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(30),
    color: Colors.white.withValues(alpha: 0.6),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

class EduBackBtn extends StatelessWidget {
  const EduBackBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 52,
        height: 52,
        decoration: eduGlassDeco(),
        child: const Icon(
          Icons.chevron_left_rounded,
          size: 34,
          color: Colors.black,
        ),
      ),
    );
  }
}

class EduGemBadge extends StatelessWidget {
  const EduGemBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: 108,
      decoration: eduGlassDeco(shape: BoxShape.rectangle),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.diamond_rounded, size: 24, color: EduColors.gem),
          const SizedBox(width: 8),
          Text(
            '5/5',
            style: AppText.style(
              18,
              weight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol "Next" di halaman baca.
class EduNextBtn extends StatelessWidget {
  const EduNextBtn({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: 108,
        alignment: Alignment.center,
        decoration: eduGlassDeco(shape: BoxShape.rectangle),
        child: Text(
          'Next',
          style: AppText.style(
            22,
            weight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

/// Tombol peta 3D (hijau tua + bayangan hijau).
class EduMapBtn extends StatelessWidget {
  const EduMapBtn({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 50,
        height: 55,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 5,
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: EduColors.listBorder,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: EduColors.forest,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.map_rounded,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
