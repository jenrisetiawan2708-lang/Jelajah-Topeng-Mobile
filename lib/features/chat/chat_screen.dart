import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/gradient_background.dart';

class _Msg {
  const _Msg({required this.fromUser, required this.text, this.source});
  final bool fromUser;
  final String text;
  final String? source;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _dark = Color(0xFF1E2F13);
  static const _sendGreen = Color(0xFF2E7D32);
  static const _suggestions = [
    'Di mana parkirnya?',
    'Jam kunjungan',
    'Siapa Mbah Reni?',
  ];

  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [
    const _Msg(
      fromUser: false,
      text:
          'Halo! Aku asisten Jelajah Topeng. Tanya apa saja tentang kampung, tiket, atau cerita topeng.',
    ),
  ];
  bool _typing = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // TODO: ganti dengan panggilan POST /api/ai/ask ke backend.
  ({String text, String? source}) _answer(String q) {
    final t = q.toLowerCase();
    if (t.contains('parkir')) {
      return (
        text:
            'Parkir motor dan mobil tersedia di halaman Kampung Budaya Polowijen. Dari area parkir ke lokasi cukup berjalan kaki sekitar 2 menit.',
        source: 'FAQ • Fasilitas',
      );
    }
    if (t.contains('jam') || t.contains('kunjungan')) {
      return (
        text:
            'Paket Medayoh berlangsung hari Sabtu pukul 13.00–17.00 WIB. Jadwal paket lain bisa kamu lihat saat memilih tanggal di menu Tiket.',
        source: 'Tiket • Paket Medayoh',
      );
    }
    if (t.contains('mbah reni')) {
      return (
        text:
            'Mbah Reni adalah salah satu tokoh penting dalam sejarah seni budaya Polowijen, khususnya dalam perkembangan Topeng Malangan.',
        source: 'Materi 1 • Mbah Reni',
      );
    }
    return (
      text:
          'Maaf, aku belum punya jawaban untuk itu. Coba tanyakan tentang kampung, tiket, atau cerita topeng.',
      source: null,
    );
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send([String? preset]) {
    final text = (preset ?? _ctrl.text).trim();
    if (text.isEmpty || _typing) return;
    setState(() {
      _messages.add(_Msg(fromUser: true, text: text));
      _typing = true;
    });
    _ctrl.clear();
    _scrollToEnd();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final a = _answer(text);
      setState(() {
        _typing = false;
        _messages.add(_Msg(fromUser: false, text: a.text, source: a.source));
      });
      _scrollToEnd();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildHeader(context),
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  children: [
                    for (var i = 0; i < _messages.length; i++) ...[
                      _buildBubble(context, _messages[i]),
                      if (i == 0) _buildChips(),
                    ],
                    if (_typing) _buildTyping(),
                  ],
                ),
              ),
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              child: const Icon(Icons.chevron_left, size: 28, color: Colors.black),
            ),
          ),
          Expanded(
            child: Text(
              'Tanya AI Jelajah Topeng',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _dark,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final s in _suggestions)
            GestureDetector(
              onTap: () => _send(s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primary, width: 1.2),
                ),
                child: Text(
                  s,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _dark,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBubble(BuildContext context, _Msg m) {
    final maxW = MediaQuery.of(context).size.width * 0.78;
    final user = m.fromUser;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxW),
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: user ? _dark : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(user ? 18 : 4),
            bottomRight: Radius.circular(user ? 4 : 18),
          ),
          boxShadow: user
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              m.text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.35,
                color: user ? Colors.white : Colors.black87,
              ),
            ),
            if (m.source != null) ...[
              const SizedBox(height: 8),
              Text(
                'Sumber: ${m.source}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTyping() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          'Sedang mengetik...',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.only(left: 18, right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.primary, width: 1.4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Tanya apa saja...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.mic_none_rounded, color: AppColors.grey),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _sendGreen,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}