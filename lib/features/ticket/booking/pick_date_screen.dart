import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../flow_widgets.dart';
import 'booking_data.dart';
import 'booking_form_screen.dart';

/// Pilih tanggal & waktu. Dibuka setelah paket dipilih.
class PickDateScreen extends StatefulWidget {
  PickDateScreen({super.key, BookingData? data}) : data = data ?? BookingData();

  final BookingData data;

  @override
  State<PickDateScreen> createState() => _PickDateScreenState();
}

class _PickDateScreenState extends State<PickDateScreen> {
  static const _slots = ['09.00', '10.00', '12.00', '15.00'];
  static const _tint = Color(0xFFEAF5E6);

  BookingData get data => widget.data;
  late DateTime _month = DateTime(data.date.year, data.date.month);

  /// Paket dengan sesi tetap (mis. "13.00–17.00") tidak memakai slot jam.
  bool get _fixedSession => data.package.time.contains('–');

  void _shiftMonth(int d) =>
      setState(() => _month = DateTime(_month.year, _month.month + d));

  bool _available(DateTime day) {
    if (day.isBefore(data.package.firstDate())) return false;
    if (data.package.saturdayOnly && day.weekday != DateTime.saturday) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      header: const FlowHeader(title: 'Pilih Tanggal & Waktu', person: true),
      bottom: _buildBottomBar(),
      children: [_buildCalendar(), _buildSlots(), _buildSummary()],
    );
  }

  Widget _arrow(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Icon(icon, size: 16, color: AppColors.primary),
    ),
  );

  Widget _buildCalendar() {
    final first = DateTime(_month.year, _month.month, 1);
    final offset = first.weekday % 7; // Minggu = 0
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final prevDays = DateTime(_month.year, _month.month, 0).day;
    final rows = ((offset + days) / 7).ceil();
    final d = data.date;

    return FlowCard(
      radius: 16,
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            _arrow(Icons.chevron_left, () => _shiftMonth(-1)),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${monthsId[_month.month - 1]} ${_month.year}',
                    style: jk(14, w: FontWeight.w800, c: FC.button),
                  ),
                  Text('Select a date below', style: jk(8, c: FC.olive)),
                ],
              ),
            ),
            _arrow(Icons.chevron_right, () => _shiftMonth(1)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final n in ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'])
              Expanded(
                child: Center(
                  child: Text(n, style: jk(9, c: FC.button)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (var r = 0; r < rows; r++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(
                    child: _dayCell(r * 7 + c - offset + 1, days, prevDays),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: _tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, size: 10, color: FC.button),
                  const SizedBox(width: 4),
                  Text(
                    '${daysEn[d.weekday % 7]}, ${d.day} ${monthsEn[d.month - 1]} ${d.year}',
                    style: jk(9, w: FontWeight.w600, c: FC.button),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, size: 11, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Save',
                    style: jk(10, w: FontWeight.w800, c: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dayCell(int n, int days, int prevDays) {
    final out = n < 1 || n > days;
    final shown = n < 1 ? prevDays + n : (n > days ? n - days : n);
    final day = DateTime(_month.year, _month.month, out ? 1 : n);
    final ok = !out && _available(day);
    final sel = !out && data.date == day;

    return GestureDetector(
      onTap: ok ? () => setState(() => data.date = day) : null,
      child: Container(
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: out
              ? null
              : (sel
                    ? AppColors.primary
                    : (ok ? _tint : _tint.withValues(alpha: 0.35))),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$shown',
          style: jk(
            11,
            w: sel ? FontWeight.w800 : FontWeight.w500,
            c: out || !ok
                ? const Color(0xFFBDBDBD)
                : (sel ? Colors.white : FC.button),
          ),
        ),
      ),
    );
  }

  Widget _buildSlots() {
    if (_fixedSession) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sesi Kunjungan', style: jk(17, w: FontWeight.w800)),
          Text('Paket ini memiliki jam sesi tetap', style: jk(12)),
          const SizedBox(height: 8),
          Container(
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _tint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary, width: 2.5),
            ),
            child: Text('${data.time} WIB', style: jk(14, w: FontWeight.w800)),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Slot Waktu tersedia', style: jk(17, w: FontWeight.w800)),
        Text('Pilih jam sesi bersama maestro', style: jk(12)),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < _slots.length; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i < _slots.length - 1 ? 8 : 0,
                  ),
                  child: _slot(_slots[i]),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _slot(String t) {
    final sel = data.time == t;
    return GestureDetector(
      onTap: () => setState(() => data.time = t),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sel ? _tint : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: sel ? 2.5 : 1.2),
        ),
        child: Text(
          t,
          style: jk(14, w: sel ? FontWeight.w800 : FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final d = data.date;
    return FlowCard(
      radius: 12,
      children: [
        Text('Ringkasan Booking', style: jk(15, w: FontWeight.w800)),
        const SizedBox(height: 8),
        KV(
          'Paket',
          data.package.name,
          labelSize: 14,
          valueSize: 14,
          labelColor: Colors.black,
        ),
        const KV(
          'Maestro',
          'Ki Sujono',
          labelSize: 14,
          valueSize: 14,
          labelColor: Colors.black,
        ),
        const KV(
          'Lokasi',
          'Sanggar Topeng',
          labelSize: 14,
          valueSize: 14,
          labelColor: Colors.black,
        ),
        KV(
          'Tanggal',
          '${d.day} ${monthsId[d.month - 1]}, ${data.time} WIB',
          labelSize: 14,
          valueSize: 14,
          labelColor: Colors.black,
        ),
        const KV(
          'Durasi',
          '90 Menit',
          labelSize: 14,
          valueSize: 14,
          labelColor: Colors.black,
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 56,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1.5),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 11,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jumlah', style: jk(11)),
                  Text(
                    rupiah(data.total, prefix: 'Rp.'),
                    style: jk(16, w: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookingFormScreen(data: data),
                ),
              ),
              child: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.darkGreen, AppColors.midGreen],
                  ),
                ),
                child: Text(
                  'Isi Data Diri',
                  style: jk(18, w: FontWeight.w800, c: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
