import 'package:flutter/material.dart';
import '../flow_widgets.dart';

/// Indikator langkah 1-2-3 (Paket > Data > Bayar).
class BookingStepBar extends StatelessWidget {
  const BookingStepBar({super.key, required this.current});

  final int current; // 1..3

  Widget _dot(int n) {
    final done = n < current;
    final now = n == current;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? FC.button : (now ? FC.dark : Colors.white),
        border: Border.all(
          color: (done || now) ? Colors.transparent : const Color(0xFFBFD8A5),
          width: 1.4,
        ),
      ),
      child: done
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : Text(
              '$n',
              style: jk(12, w: FontWeight.w800, c: now ? Colors.white : FC.muted),
            ),
    );
  }

  Widget _line(bool active) => Expanded(
        child: Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          color: active ? FC.button : const Color(0xFFBFD8A5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(1),
        _line(current > 1),
        _dot(2),
        _line(current > 2),
        _dot(3),
        const SizedBox(width: 10),
        Text('Paket › Data › Bayar', style: jk(11, c: FC.muted)),
      ],
    );
  }
}