import 'package:flutter/material.dart';
import '../flow_widgets.dart';
import 'ticket_detail_screen.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      header: const FlowHeader(person: true),
      gap: 16,
      children: [
        for (final n in [2, 1])
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Riwayat Tiket $n', style: jk(18, w: FontWeight.w800)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TicketDetailScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF7CC47A), width: 1.3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking Sesi Ki Sujono', style: jk(15)),
                      Text('Tempat Sanggar Topeng', style: jk(15)),
                      Text('90 Menit', style: jk(15)),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}