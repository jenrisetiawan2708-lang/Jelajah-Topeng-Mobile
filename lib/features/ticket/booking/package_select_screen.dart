import 'package:flutter/material.dart';

import '../../../shared/widgets/dark_button.dart';
import '../../education/edu_header.dart';
import '../flow_widgets.dart';
import 'booking_data.dart';
import '../ticket_history_view.dart';
import 'pick_date_screen.dart';

enum _TiketView { pesan, riwayat }

/// Pilih paket kunjungan (desain "Redesign Ticket"): langsung satu halaman,
/// tanpa stepper tahapan.
class PackageSelectScreen extends StatefulWidget {
  const PackageSelectScreen({super.key, this.initial});

  /// Paket yang dipilih dari awal (mis. dari tombol "Pesan Lagi").
  final TicketPackage? initial;

  @override
  State<PackageSelectScreen> createState() => _PackageSelectScreenState();
}

class _PackageSelectScreenState extends State<PackageSelectScreen> {
  static const _filters = ['Semua', 'Sabtu', '3–10 orang', 'Pelajar'];
  static const _maxPeople = 100;
  static const _border = Color(0xFFCFE7B0);
  static const _tagBorder = Color(0xFFB9C4AE);
  static const _green = Color(0xFF5BAA55);

  _TiketView _view = _TiketView.pesan;
  int _people = 4;
  String _filter = 'Semua';
  TicketPackage? _selected;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    if (init != null) {
      _people = init.fits(_people) ? _people : init.minPeople;
      _selected = init;
    } else {
      _selected = _firstFitting();
    }
  }

  TicketPackage? _firstFitting() {
    for (final p in kPackages) {
      if (p.fits(_people)) return p;
    }
    return null;
  }

  bool _matchesFilter(TicketPackage p) {
    switch (_filter) {
      case 'Sabtu':
        return p.saturdayOnly;
      case '3–10 orang':
        return p.minPeople <= 10 && p.maxPeople >= 3;
      case 'Pelajar':
        return p.tags.contains('Pelajar');
      default:
        return true;
    }
  }

  void _setPeople(int n) {
    final v = n < 1 ? 1 : (n > _maxPeople ? _maxPeople : n);
    setState(() {
      _people = v;
      final sel = _selected;
      if (sel == null || !sel.fits(v)) _selected = _firstFitting();
    });
  }

  /// Dari "Pesan Lagi" di riwayat: kembali ke pilih paket dengan paket terpilih.
  void _reorder(String packageName) {
    TicketPackage? p;
    for (final k in kPackages) {
      if (k.name == packageName) p = k;
    }
    setState(() {
      _view = _TiketView.pesan;
      _filter = 'Semua';
      if (p != null) {
        if (!p.fits(_people)) _people = p.minPeople;
        _selected = p;
      }
    });
  }

  void _continue() {
    final p = _selected;
    if (p == null) return;
    final data = BookingData(package: p)
      ..tickets = _people
      ..date = p.firstDate();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => PickDateScreen(data: data)));
  }

  BoxDecoration _box({
    Color border = _border,
    double width = 1.2,
    double radius = 20,
  }) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border, width: width),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final visible = kPackages.where(_matchesFilter).toList();
    final total = _selected?.totalFor(_people) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFD2EEA4),
      body: EduBackground(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(children: [EduBackBtn(), Spacer(), EduGemBadge()]),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildToggle(),
              ),
              if (_view == _TiketView.riwayat)
                Expanded(child: TicketHistoryView(onReorder: _reorder))
              else ...[
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                    children: [
                      Text(
                        'Pilih Paket Kunjungan',
                        style: jk(22, w: FontWeight.w800, c: FC.dark),
                      ),
                      const SizedBox(height: 12),
                      _buildPeopleCard(),
                      const SizedBox(height: 14),
                      _buildFilters(),
                      const SizedBox(height: 14),
                      if (visible.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Tidak ada paket untuk filter ini.',
                              style: jk(13, c: FC.muted),
                            ),
                          ),
                        )
                      else
                        for (final p in visible) ...[
                          _buildCard(p),
                          const SizedBox(height: 10),
                        ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: _buildBottomBar(total),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------ toggle atas
  Widget _buildToggle() {
    Widget seg(String label, bool on, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? FC.dark : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              label,
              style: jk(
                13,
                w: on ? FontWeight.w700 : FontWeight.w500,
                c: on ? Colors.white : FC.dark,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          seg(
            'Pesan Tiket',
            _view == _TiketView.pesan,
            () => setState(() => _view = _TiketView.pesan),
          ),
          seg(
            'Riwayat Pesanan',
            _view == _TiketView.riwayat,
            () => setState(() => _view = _TiketView.riwayat),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------ jumlah orang
  Widget _round(IconData icon, VoidCallback onTap, {required bool dark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dark ? FC.dark : Colors.white,
          border: Border.all(color: FC.dark, width: 1.4),
        ),
        child: Icon(icon, size: 20, color: dark ? Colors.white : FC.dark),
      ),
    );
  }

  Widget _buildPeopleCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
      decoration: _box(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Berapa orang yang ikut?', style: jk(11.5, c: FC.muted)),
                const SizedBox(height: 2),
                Text(
                  'Kami tunjukkan paket yang cocok',
                  style: jk(14, w: FontWeight.w800, c: FC.dark),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _round(Icons.remove, () => _setPeople(_people - 1), dark: false),
          SizedBox(
            width: 44,
            child: Center(
              child: Text(
                '$_people',
                style: jk(24, w: FontWeight.w800, c: FC.dark),
              ),
            ),
          ),
          _round(Icons.add, () => _setPeople(_people + 1), dark: true),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ filter
  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in _filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: _filter == f ? FC.dark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _filter == f ? FC.dark : _tagBorder,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    f,
                    style: jk(
                      12.5,
                      w: _filter == f ? FontWeight.w700 : FontWeight.w500,
                      c: _filter == f ? Colors.white : FC.dark,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------- kartu paket
  Widget _radio(bool on) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? _green : Colors.white,
        border: Border.all(
          color: on ? _green : const Color(0xFFBFC8B8),
          width: 1.4,
        ),
      ),
    );
  }

  Widget _outlineTag(String text, {bool bold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _tagBorder, width: 1),
      ),
      child: Text(
        text,
        style: jk(
          10.5,
          w: bold ? FontWeight.w600 : FontWeight.w500,
          c: FC.muted,
        ),
      ),
    );
  }

  Widget _buildCard(TicketPackage p) {
    final fits = p.fits(_people);
    final sel = identical(_selected, p);

    return Opacity(
      opacity: fits ? 1 : 0.6,
      child: GestureDetector(
        onTap: () {
          if (!fits) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    '${p.name} untuk ${p.minPeople}–${p.maxPeople} orang',
                  ),
                ),
              );
            return;
          }
          setState(() => _selected = p);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          decoration: _box(
            border: sel ? _green : _border,
            width: sel ? 2 : 1.2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: jk(16, w: FontWeight.w800, c: FC.dark),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          p.priceLabel,
                          style: jk(12.5, w: FontWeight.w700, c: FC.dark),
                        ),
                        _outlineTag('${p.minPeople}–${p.maxPeople} orang'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final c in p.chips) _outlineTag(c, bold: true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _radio(sel),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------- bar bawah
  Widget _buildBottomBar(int total) {
    final enabled = _selected != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
      decoration: _box(radius: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Jumlah', style: jk(12, c: FC.muted)),
                Text(
                  rupiah(total),
                  style: jk(20, w: FontWeight.w800, c: FC.dark),
                ),
              ],
            ),
          ),
          Opacity(
            opacity: enabled ? 1 : 0.5,
            child: IgnorePointer(
              ignoring: !enabled,
              child: DarkButton(
                text: 'Lanjut',
                width: 120,
                height: 46,
                fontSize: 16,
                radius: 23,
                onPressed: _continue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
