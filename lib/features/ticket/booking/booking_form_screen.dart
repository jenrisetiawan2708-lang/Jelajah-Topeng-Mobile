import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widgets/dark_button.dart';
import '../flow_widgets.dart';
import 'booking_data.dart';
import 'payment_qr_screen.dart';

/// Data pemesan (desain Figma "Data Pemesanan").
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
  final Map<int, TextEditingController> _companions = {}; // Peserta 2..N
  final Set<int> _open = {};
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
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    for (final c in _companions.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _companion(int i) =>
      _companions.putIfAbsent(i, () => TextEditingController());

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

  /// Nama peserta lain boleh kosong; kalau diisi harus valid.
  String? _companionError(int i) {
    final t = (_companions[i]?.text ?? '').trim();
    return t.isEmpty ? null : _nameError(t);
  }

  bool get _valid {
    if (_nameError(_name.text) != null || _phoneError(_phone.text) != null) {
      return false;
    }
    for (var i = 2; i <= _people; i++) {
      if (_companionError(i) != null) return false;
    }
    return true;
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
    if (!_valid) return;
    final d = widget.data;
    d.name = _name.text.trim();
    d.phone = _phone.text.trim();
    d.tickets = _people;
    d.companions = [
      for (var i = 2; i <= _people; i++)
        if ((_companions[i]?.text ?? '').trim().isNotEmpty)
          _companions[i]!.text.trim(),
    ];
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => PaymentQrScreen(data: d)));
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final p = d.package;
    final total = p.totalFor(_people);

    return FlowScaffold(
      header: const FlowHeader(title: 'Data Pemesanan', person: true),
      gap: 14,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummary(p, total),
          const SizedBox(height: 10),
          _valid
              ? DarkButton(
                  text: 'Lanjut ke Pembayaran',
                  height: 56,
                  fontSize: 17,
                  radius: 28,
                  onPressed: _next,
                )
              : Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBDBDBD),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Text(
                    'Lanjut ke Pembayaran',
                    style: jk(17, w: FontWeight.w700, c: Colors.white),
                  ),
                ),
        ],
      ),
      children: [
        _buildSchedule(d),
        _buildPeople(p),
        Text('Data Pemesan', style: jk(15, w: FontWeight.w800)),
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
        for (var i = 2; i <= _people; i++) _companionCard(i),
      ],
    );
  }

  // Kartu paket + "Ubah" (kembali ke pilih tanggal & waktu).
  Widget _buildSchedule(BookingData d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FC.olive, width: 1.4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.package.name,
                  style: jk(15, w: FontWeight.w800, c: FC.dark),
                ),
                const SizedBox(height: 2),
                Text(
                  '${dateShortId(d.date)} · ${d.time} WIB',
                  style: jk(11.5, c: FC.muted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                'Ubah',
                style: jk(13, w: FontWeight.w800, c: FC.dark),
              ),
            ),
          ),
        ],
      ),
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Jumlah peserta', style: jk(14, w: FontWeight.w800)),
            Text('Maks. ${p.maxPeople} orang', style: jk(11.5, c: FC.muted)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _stepBtn(Icons.remove, () => _setPeople(_people - 1), dark: false),
            SizedBox(
              width: 64,
              child: Center(
                child: Text(
                  '$_people',
                  style: jk(22, w: FontWeight.w800, c: FC.dark),
                ),
              ),
            ),
            _stepBtn(Icons.add, () => _setPeople(_people + 1), dark: true),
          ],
        ),
      ],
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
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
            child: Text(
              error,
              style: jk(11, w: FontWeight.w700, c: FC.redDark),
            ),
          ),
      ],
    );
  }

  // Peserta 2..N: bisa dibuka-tutup, nama opsional.
  Widget _companionCard(int i) {
    final c = _companion(i);
    final text = c.text.trim();
    final err = _companionError(i);
    final ok = text.isNotEmpty && err == null;
    final open = _open.contains(i);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ok ? FC.button : FC.olive, width: 1.4),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              if (open) {
                _open.remove(i);
              } else {
                _open.add(i);
              }
            }),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Peserta $i',
                      style: jk(14, w: FontWeight.w800, c: FC.dark),
                    ),
                  ),
                  if (ok)
                    const Icon(Icons.check_circle, color: FC.button, size: 22)
                  else if (err != null)
                    const Icon(Icons.cancel, color: FC.redDark, size: 22)
                  else
                    Text('Opsional', style: jk(11, c: FC.muted)),
                  const SizedBox(width: 6),
                  Icon(
                    open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: FC.dark,
                  ),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: _field(
                label: 'Nama lengkap',
                controller: c,
                hint: 'Nama peserta (opsional)',
                type: TextInputType.name,
                error: err,
                touched: text.isNotEmpty,
                onChanged: (_) => setState(() {}),
              ),
            ),
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
              Text(rupiah(total), style: jk(12, w: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: jk(15, w: FontWeight.w800)),
              Text(
                rupiah(total),
                style: jk(22, w: FontWeight.w800, c: FC.dark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
