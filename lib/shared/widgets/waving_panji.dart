import 'package:flutter/material.dart';

/// Panji dengan tangan yang melambai terus selama halaman terbuka.
class WavingPanji extends StatefulWidget {
  const WavingPanji({super.key});

  @override
  State<WavingPanji> createState() => _WavingPanjiState();
}

class _WavingPanjiState extends State<WavingPanji>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/splash/char_body.png'),
        AnimatedBuilder(
          animation: _c,
          builder: (_, child) => Transform(
            alignment: const Alignment(-0.648, 0.143),
            transform: Matrix4.rotationZ(
              (Curves.easeInOut.transform(_c.value) - 0.5) * 0.64,
            ),
            child: child,
          ),
          child: Image.asset('assets/splash/char_arm.png'),
        ),
        Image.asset('assets/splash/char_mask.png'),
      ],
    );
  }
}