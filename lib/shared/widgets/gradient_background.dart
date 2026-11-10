import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.colors = const [AppColors.bgTop, Colors.white, AppColors.bgBottom],
    this.stops = const [0.0, 0.45, 1.0],
  });

  final Widget child;
  final List<Color> colors;
  final List<double> stops;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: stops,
        ),
      ),
      child: child,
    );
  }
}