import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/gradient_background.dart';
import '../education/edu_style.dart';
import '../profile/profile_screen.dart';

TextStyle jk(double size,
        {FontWeight w = FontWeight.w400, Color c = Colors.black, double? h}) =>
    GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: w, color: c, height: h);

class FC {
  static const dark = Color(0xFF2D4A1E);
  static const button = Color(0xFF3A6B2A);
  static const red = Color(0xFFC8553D);
  static const redDark = Color(0xFFC0392B);
  static const muted = Color(0xFF8A8F86);
  static const beige = Color(0xFFF3EDE0);
  static const gold = Color(0xFFD9A441);
  static const olive = Color(0xFF7CAF4F);
  static const ink = Color(0xFF1A1A1A);
}

/// Kembali ke halaman Riwayat Tiket ("Tiket saya").
void backToTickets(BuildContext context) {
  Navigator.of(context)
      .popUntil((r) => r.settings.name == 'riwayat' || r.isFirst);
}

class FlowHeader extends StatelessWidget {
  const FlowHeader({
    super.key,
    this.title,
    this.titleColor = Colors.black,
    this.pill,
    this.person = false,
  });

  final String? title;
  final Color titleColor;
  final String? pill; // label kanan atas, mis. "Refund"
  final bool person; // ikon orang kanan atas

  Widget _circle(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          child: Icon(icon, size: 28, color: Colors.black),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _circle(Icons.chevron_left, () => Navigator.maybePop(context)),
          if (title != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(title!,
                  style: jk(20, w: FontWeight.w800, c: titleColor)),
            ),
          ] else
            const Spacer(),
          if (pill != null)
            GestureDetector(
              // "Tiket saya" -> kembali ke Riwayat Tiket
              onTap: pill == 'Tiket saya' ? () => backToTickets(context) : null,
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Text(pill!, style: jk(16, w: FontWeight.w800)),
              ),
            ),
          if (person)
            _circle(
              Icons.person_outline,
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
        ],
      ),
    );
  }
}

/// Kerangka halaman: gradasi + header + isi yang bisa di-scroll + tombol bawah.
class FlowScaffold extends StatelessWidget {
  const FlowScaffold({
    super.key,
    required this.header,
    required this.children,
    this.bottom,
    this.centered = false,
    this.gap = 12,
  });

  final Widget header;
  final List<Widget> children;
  final Widget? bottom;
  final bool centered;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(SizedBox(height: gap));
      items.add(children[i]);
    }
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items,
    );
    final scroll = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: column,
    );

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              header,
              Expanded(child: centered ? Center(child: scroll) : scroll),
              if (bottom != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: bottom,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlowCard extends StatelessWidget {
  const FlowCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(14),
    this.radius = 22,
  });

  final List<Widget> children;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: FC.olive, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class FlowLine extends StatelessWidget {
  const FlowLine({super.key});

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 18, thickness: 1, color: Color(0xFFEFEFEF));
}

/// Label merah + judul besar + subjudul (+ garis pemisah).
class FlowTitle extends StatelessWidget {
  const FlowTitle({
    super.key,
    this.label,
    required this.title,
    this.subtitle,
    this.line = true,
  });

  final String? label;
  final String title;
  final String? subtitle;
  final bool line;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(label!, style: jk(11, w: FontWeight.w800, c: FC.red)),
        Text(title, style: jk(26, w: FontWeight.w800, c: FC.dark, h: 1.15)),
        if (subtitle != null)
          Text(subtitle!, style: jk(11.5, c: FC.muted)),
        if (line) const FlowLine(),
      ],
    );
  }
}

/// Baris "label ........ nilai".
class KV extends StatelessWidget {
  const KV(
    this.label,
    this.value, {
    super.key,
    this.labelSize = 12,
    this.valueSize = 12,
    this.labelColor = FC.muted,
    this.valueColor = FC.ink,
    this.valueWeight = FontWeight.w700,
  });

  final String label;
  final String value;
  final double labelSize;
  final double valueSize;
  final Color labelColor;
  final Color valueColor;
  final FontWeight valueWeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: jk(labelSize, c: labelColor)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: jk(valueSize, w: valueWeight, c: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kotak beige dengan ikon kutipan (tebal) atau ikon info.
class InfoBox extends StatelessWidget {
  const InfoBox(this.text, {super.key, this.quote = true});

  final String text;
  final bool quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: FC.beige,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(quote ? Icons.format_quote : Icons.info_outline,
              color: FC.gold, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: quote
                  ? jk(12.5, w: FontWeight.w700, c: FC.dark)
                  : jk(11.5, c: const Color(0xFF444444), h: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class FlowButton extends StatelessWidget {
  const FlowButton({
    super.key,
    required this.text,
    this.onTap,
    this.onLongPress,
    this.outlinedRed = false,
    this.icon,
    this.enabled = true,
    this.height = 46,
  });

  final String text;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool outlinedRed;
  final IconData? icon;
  final bool enabled;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = outlinedRed ? FC.redDark : Colors.white;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: outlinedRed ? Colors.white : FC.button,
            borderRadius: BorderRadius.circular(height / 2),
            border: outlinedRed ? Border.all(color: FC.redDark, width: 1.4) : null,
            boxShadow: outlinedRed
                ? null
                : const [BoxShadow(color: Color(0xFF6AA83A), offset: Offset(0, 2))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text, style: jk(14, w: FontWeight.w800, c: color)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu kecil: "Pengajuan refund ... Langkah 1 dari 3" + bar + keterangan.
class StepCard extends StatelessWidget {
  const StepCard({
    super.key,
    required this.label,
    required this.right,
    required this.value,
    required this.caption,
    this.color = FC.button,
    this.rightColor = FC.dark,
  });

  final String label;
  final String right;
  final double value; // 0..1
  final String caption;
  final Color color;
  final Color rightColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: jk(11, c: FC.muted)),
              Text(right, style: jk(14, w: FontWeight.w800, c: rightColor)),
            ],
          ),
          const SizedBox(height: 6),
          EduBar(value: value, color: color, height: 7),
          const SizedBox(height: 6),
          Text(caption, style: jk(10.5, c: FC.muted)),
        ],
      ),
    );
  }
}

/// Gambar QR dari assets (cadangan: ikon QR).
class QrImage extends StatelessWidget {
  const QrImage({super.key, this.size = 190});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/qr_payment.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(Icons.qr_code_2, size: size),
    );
  }
}