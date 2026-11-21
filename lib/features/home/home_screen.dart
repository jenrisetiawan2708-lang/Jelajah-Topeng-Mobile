import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../chat/chat_screen.dart';
import '../education/education_screen.dart';
import '../game/game_map_screen.dart';
import '../profile/profile_screen.dart';
import '../ticket/booking/package_select_screen.dart';
import 'home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  // Urutan: Beranda, Education, Game, Ticket, Profile
  static const _gameIndex = 2;
  static const _tiketIndex = 3;

  void _openChat() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ChatScreen()));
  }

  void _onNavTap(int i) {
    // Game dan Ticket dibuka sebagai layar penuh (route baru), navbar tidak ikut.
    if (i == _gameIndex) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const GameMapScreen()));
      return;
    }
    if (i == _tiketIndex) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const PackageSelectScreen()));
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.mintBottom,
      body: IndexedStack(
        index: _index,
        children: const [
          HomeTab(),
          EducationScreen(),
          SizedBox.shrink(), // slot Game: layar penuh, bukan tab
          SizedBox.shrink(), // slot Ticket: layar penuh, bukan tab
          ProfileScreen(),
        ],
      ),
      floatingActionButton: _index == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton.extended(
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
              ),
            )
          : null,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: AppBottomNav(currentIndex: _index, onTap: _onNavTap),
        ),
      ),
    );
  }
}
