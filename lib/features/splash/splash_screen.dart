import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/waving_panji.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const double _totalMs = 3600;
  static const Color _bg = Color(0xFF1E2F13);

  static const _body = 'assets/splash/char_body.png';
  static const _arm = 'assets/splash/char_arm.png';
  static const _mask = 'assets/splash/char_mask.png';

  late final AnimationController _c;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalMs.toInt()),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    Future.wait([
      precacheImage(const AssetImage(_body), context),
      precacheImage(const AssetImage(_arm), context),
      precacheImage(const AssetImage(_mask), context),
    ]).then((_) {
      if (mounted) _c.forward().whenComplete(_goNext);
    });
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => const OnboardingScreen(),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // progres 0..1 antara ms a sampai b
  double _seg(double ms, double a, double b, [Curve curve = Curves.linear]) {
    return curve.transform(((ms - a) / (b - a)).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width * 0.72;

    return Scaffold(
      backgroundColor: _bg,
      body: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final ms = _c.value * _totalMs;
            final enter = _seg(ms, 0, 900, Curves.easeOutCubic);
            final titleOpacity = _seg(ms, 600, 1300);

            return Column(
              children: [
                const Spacer(flex: 4),
                SizedBox(
                  width: s,
                  height: s,
                  child: ClipOval(
                    child: ColoredBox(
                      color: Colors.white,
                      child: Transform.translate(
                        offset: Offset((1 - enter) * s * 0.9, 0),
                        child: const WavingPanji(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Opacity(
                  opacity: titleOpacity,
                  child: Text(
                    'Jelajah Topeng',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(flex: 6),
              ],
            );
          },
        ),
      ),
    );
  }
}