import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/dark_button.dart';
import '../flow_widgets.dart';
import 'booking_data.dart';
import 'payment_qr_screen.dart';
import 'step_bar.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key, required this.data});

  final BookingData data;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  static const _border = Color(0xFFCFE7B0);

  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _nameTouched = false;
  bool _phoneTouched = false;
  late int _people;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    final p = d.package;
    _name.text = d.name;
    _phone.text = d.phone;
    _nameTouched = d.name.isNotEmpty;
    _phoneTouched = d.phone.isNotEmpty;
    _people = d.tickets < p.minPeople
        ? p.minPeople
        : (d.tickets > p.maxPeople ? p.maxPeople : d.tickets);

    // Pastikan tanggal valid untuk paket ini (besok atau lebih, dan hari Sabtu
    // untuk paket yang hanya buka hari Sabtu).
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (d.date.isBefore(tomorrow) ||
        (p.saturdayOnly && d.date.weekday != DateTime.saturday)) {
      d.date = p.firstDate();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  String? _nameError(String v) {
    final t = v.trim();
    if (t.isEmpty) return 'Nama lengkap wajib diisi';
    if (t.length < 3) return 'Nama minimal 3 karakter';
    if (RegExp(r'\d').hasMatch(t)) return 'Nama tidak boleh mengandung angka';
    if (!RegExp(r"^[\p{L}\s.,'’-]+$", unicode: true).hasMatch(t)) {
      return 'Nama hanya boleh berisi huruf';
    }
    return null;
  }

  String? _phoneError(String v) {
    final digits = v.replaceAll(RegExp(r'[\s-]'), '');
    if (digits.isEmpty) return 'Nomor HP wajib diisi';
    if (!RegExp(r'^\+?\d+$').hasMatch(digits)) {
      return 'Nomor HP hanya boleh berisi angka';
    }
    final normalized = digits.startsWith('+62')
        ? '0${digits.substring(3)}'
        : digits.startsWith('62')
            ? '0${digits.substring(2)}'
            : digits;
    if (!normalized.startsWith('08')) {
      return 'Nomor HP harus diawali 08 atau +62. Contoh: 081234567890';
    }
    if (normalized.length < 10) {
      return 'Nomor HP kurang ${10 - normalized.length} angka. Contoh: 081234567890';
    }
    if (normalized.length > 13) {
      return 'Nomor HP terlalu panjang (maksimal 13 angka)';
    }
    return null;
  }

  Future<void> _changeDate() async {
    final d = widget.data;
    final p = d.package;
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day + 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: d.date,
      firstDate: first,
      lastDate: first.add(const Duration(days: 180)),
      selectableDayPredicate: (day) =>
          !p.saturdayOnly || day.weekday == DateTime.saturday,
    );
    if (picked != null) setState(() => d.date = picked);
  }

  void _setPeople(int n) {
    final p = widget.data.package;
    if (n < p.minPeople || n > p.maxPeople) return;
    setState(() => _people = n);
  }

  void _next() {
    setState(() {
      _nameTouched = true;
      _phoneTouched = true;
    });
    if (_nameError(_name.text) != null || _phoneError(_phone.text) != null) {
      return;
    }
    final d = widget.data;
    d.name = _name.text.trim();
    d.phone = _phone.text.trim();
    d.tickets = _people;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PaymentQrScreen(data: d)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final p = d.package;
    final total = p.totalFor(_people);

    return FlowScaffold(
      header: const FlowHeader(title: 'Data Pemesan'),
      gap: 14,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummary(p, total),
          const SizedBox(height: 10),
          DarkButton(
            text: 'Lanjut ke Pembayaran',
            height: 56,
            fontSize: 17,
            radius: 28,
            onPressed: _next,
          ),
        ],
      ),
      children: [
        const BookingStepBar(current: 2),
        _buildSchedule(d),
        _field(
          label: 'Nama lengkap',
          controller: _name,
          hint: 'Contoh: Rangga Pratama',
          type: TextInputType.name,
          error: _nameError(_name.text),
          touched: _nameTouched,
          onChanged: (_) => setState(() => _nameTouched = true),
        ),
        _field(
          label: 'Nomor HP',
          controller: _phone,
          hint: 'Contoh: 081234567890',
          type: TextInputType.phone,
          error: _phoneError(_phone.text),
          touched: _phoneTouched,
          formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]'))],
          onChanged: (_) => setState(() => _phoneTouched = true),
        ),
        _buildPeople(p),
      ],
    );
  }

  Widget _buildSchedule(BookingData d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.package.name,
                    style: jk(15, w: FontWeight.w800, c: FC.dark)),
                const SizedBox(height: 2),
                Text('${dateShortId(d.date)} · ${d.time} WIB',
                    style: jk(11.5, c: FC.muted)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _changeDate,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Text('Ubah',
                  style: jk(13, w: FontWeight.w800, c: FC.button)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required TextInputType type,
    required String? error,
    required bool touched,
    required ValueChanged<String> onChanged,
    List<TextInputFormatter>? formatters,
  }) {
    final show = touched && error != null;
    final ok = touched && error == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: jk(12, w: FontWeight.w700)),
        const SizedBox(height: 6),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: show
                  ? FC.redDark
                  : (ok ? FC.button : const Color(0xFF7CC47A)),
              width: show || ok ? 1.6 : 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: type,
            inputFormatters: formatters,
            onChanged: onChanged,
            style: jk(14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: jk(14, c: FC.muted),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: show
                  ? const Icon(Icons.cancel, color: FC.redDark)
                  : (ok
                      ? const Icon(Icons.check_circle, color: FC.button)
                      : null),
            ),
          ),
        ),
        if (show)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(error, style: jk(11, c: FC.redDark)),
          ),
      ],
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap, {required bool dark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dark ? FC.dark : Colors.white,
          border: Border.all(color: FC.dark, width: 1.4),
        ),
        child: Icon(icon, size: 22, color: dark ? Colors.white : FC.dark),
      ),
    );
  }

  Widget _buildPeople(TicketPackage p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jumlah peserta',
                    style: jk(14, w: FontWeight.w800, c: FC.dark)),
                const SizedBox(height: 2),
                Text('Maks. ${p.maxPeople} orang',
                    style: jk(11, c: FC.muted)),
              ],
            ),
          ),
          _stepBtn(Icons.remove, () => _setPeople(_people - 1), dark: false),
          SizedBox(
            width: 48,
            child: Center(
              child: Text('$_people',
                  style: jk(22, w: FontWeight.w800, c: FC.dark)),
            ),
          ),
          _stepBtn(Icons.add, () => _setPeople(_people + 1), dark: true),
        ],
      ),
    );
  }

  Widget _buildSummary(TicketPackage p, int total) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                p.flatTotal != null
                    ? 'Paket tetap (maks. ${p.maxPeople} orang)'
                    : '$_people orang × ${rupiah(p.price)}',
                style: jk(12, c: FC.muted),
              ),
              Text(rupiah(total), style: jk(12, c: FC.muted)),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFEFEFEF)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: jk(14, w: FontWeight.w800)),
              Text(rupiah(total),
                  style: jk(20, w: FontWeight.w800, c: FC.dark)),
            ],
          ),
        ],
      ),
    );
  }
}