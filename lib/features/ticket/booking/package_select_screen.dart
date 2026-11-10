import 'package:flutter/material.dart';
import '../../../shared/widgets/dark_button.dart';
import '../flow_widgets.dart';
import 'booking_data.dart';
import 'booking_form_screen.dart';
import 'step_bar.dart';

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

  void _continue() {
    final p = _selected;
    if (p == null) return;
    final data = BookingData(package: p)
      ..tickets = _people
      ..date = p.firstDate();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookingFormScreen(data: data)),
    );
  }

  BoxDecoration _box({Color border = _border, double width = 1.2}) =>
      BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
    TicketPackage? recommended;
    for (final p in visible) {
      if (p.fits(_people)) {
        recommended = p;
        break;
      }
    }
    final total = _selected?.totalFor(_people) ?? 0;

    return FlowScaffold(
      header: const FlowHeader(title: 'Pilih Paket Kunjungan'),
      gap: 14,
      bottom: _buildBottomBar(total),
      children: [
        const BookingStepBar(current: 1),
        _buildPeopleCard(),
        _buildFilters(),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('Tidak ada paket untuk filter ini.',
                  style: jk(13, c: FC.muted)),
            ),
          )
        else
          for (final p in visible) _buildCard(p, recommended),
      ],
    );
  }

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
      padding: const EdgeInsets.all(14),
      decoration: _box(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Berapa orang yang ikut?',
                    style: jk(14, w: FontWeight.w800, c: FC.dark)),
                const SizedBox(height: 4),
                Text('Kami tunjukkan paket yang cocok',
                    style: jk(11.5, c: FC.muted)),
              ],
            ),
          ),
          _round(Icons.remove, () => _setPeople(_people - 1), dark: false),
          SizedBox(
            width: 44,
            child: Center(
              child: Text('$_people',
                  style: jk(20, w: FontWeight.w800, c: FC.dark)),
            ),
          ),
          _round(Icons.add, () => _setPeople(_people + 1), dark: true),
        ],
      ),
    );
  }

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _filter == f ? FC.dark : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _filter == f ? FC.dark : _border,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    f,
                    style: jk(
                      12,
                      w: FontWeight.w700,
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

  Widget _check(bool on) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? FC.button : Colors.white,
        border: Border.all(
          color: on ? FC.button : const Color(0xFFBFC8B8),
          width: 1.4,
        ),
      ),
      child: on
          ? const Icon(Icons.check, size: 18, color: Colors.white)
          : null,
    );
  }

  Widget _buildCard(TicketPackage p, TicketPackage? recommended) {
    final fits = p.fits(_people);
    final sel = identical(_selected, p);

    return Opacity(
      opacity: fits ? 1 : 0.55,
      child: GestureDetector(
        onTap: () {
          if (!fits) {
            ScaffoldMessenger.of(context).showSnackBar(
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(14),
              decoration: _box(
                border: sel ? FC.button : _border,
                width: sel ? 2.2 : 1.2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            style: jk(16, w: FontWeight.w800, c: FC.dark)),
                        const SizedBox(height: 2),
                        Text(p.info, style: jk(11.5, c: FC.muted)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final c in p.chips)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF5E6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(c,
                                    style: jk(10.5,
                                        w: FontWeight.w600, c: FC.button)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(p.priceLabel,
                            style: jk(15, w: FontWeight.w800, c: FC.dark)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _check(sel),
                ],
              ),
            ),
            if (identical(p, recommended))
              Positioned(
                top: 0,
                right: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: FC.button,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Cocok untuk $_people orang',
                      style: jk(10, w: FontWeight.w800, c: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(int total) {
    final enabled = _selected != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
      decoration: _box(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total perkiraan', style: jk(11, c: FC.muted)),
                Text(rupiah(total),
                    style: jk(20, w: FontWeight.w800, c: FC.dark)),
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