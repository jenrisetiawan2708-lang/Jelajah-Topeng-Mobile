import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../chat/chat_screen.dart';
import '../ticket/ticket_tab.dart';
import 'home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _items = [
    (Icons.home_rounded, 'Beranda'),
    (Icons.menu_book_rounded, 'Materi'),
    (Icons.location_on_rounded, 'Jelajah'),
    (Icons.sports_esports_rounded, 'Game'),
    (Icons.confirmation_number_rounded, 'Tiket'),
  ];

  static const _tiketIndex = 4;

  void _openChat() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.mintBottom,
      body: IndexedStack(
        index: _index,
        children: [
          const HomeTab(),
          for (var i = 1; i < _items.length; i++)
            i == _tiketIndex
                ? const TiketTab()
                : _ComingSoon(label: _items[i].$2),
        ],
      ),
      floatingActionButton: (_index == 0 || _index == _tiketIndex)
          ? FloatingActionButton.extended(
              onPressed: _openChat,
              backgroundColor: AppColors.forest,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: const StadiumBorder(),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
              label: Text(
                'Tanya AI',
                style: AppText.style(
                  14,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavButton(
                    icon: _items[i].$1,
                    label: _items[i].$2,
                    selected: i == _index,
                    onTap: () => setState(() => _index = i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.forest : AppColors.muted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.lime : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppText.style(
                11,
                weight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label (segera hadir)',
        style: AppText.style(16, color: AppColors.muted),
      ),
    );
  }
}