import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

/// Layar onboarding: foto Panji di atas, panel hijau tua melengkung di bawah.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const _image = 'assets/images/onboarding_panji.png';
  static const _dark = Color(0xFF1E2D14);
  static const _lightGreen = Color(0xFF7FD06F);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _dark,
      body: Stack(
        children: [
          // Foto di bagian atas.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: h * 0.62,
            child: Image.asset(
              _image,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: Color(0xFFB9E3E0)),
            ),
          ),

          // Panel melengkung (dua lapis hijau).
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: h * 0.52,
            child: const CustomPaint(painter: _DomePainter()),
          ),

          // Teks dan tombol.
          Positioned(
            left: 24,
            right: 24,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset + 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Petualangan Budaya\nDimulai dari Sini!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                      children: const [
                        TextSpan(
                          text: 'Setiap tempat adalah dunia baru yang\nsiap ',
                        ),
                        TextSpan(
                          text: 'Kamu Taklukkan.',
                          style: TextStyle(
                            color: _lightGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _PrimaryButton(
                    text: 'Mulai Petualangan',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _OutlineButton(
                    text: 'Saya sudah punya Akun',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF5BAA55), Color(0xFF8CD184)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5BAA55).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF4CAF50), width: 1.6),
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Dua lapisan lengkung: hijau agak terang di belakang, hijau tua di depan.
class _DomePainter extends CustomPainter {
  const _DomePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    Path dome(double top, double lift) => Path()
      ..moveTo(0, top + lift)
      ..quadraticBezierTo(w / 2, top - lift, w, top + lift)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    // Lapisan belakang (tipis, lebih terang).
    canvas.drawPath(
      dome(0, h * 0.10),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3F7A3C), Color(0xFF28431C)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    // Lapisan depan (hijau tua).
    canvas.drawPath(
      dome(h * 0.035, h * 0.10),
      Paint()..color = const Color(0xFF1E2D14),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
