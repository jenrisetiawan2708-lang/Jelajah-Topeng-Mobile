import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/asset_image_box.dart';
import '../../shared/widgets/circle_back_button.dart';
import '../../shared/widgets/dark_button.dart';
import '../../shared/widgets/gradient_background.dart';
import '../chat/chat_screen.dart';
import '../auth/login_screen.dart';
import '../notification/notification_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _avatar = 'assets/images/avatar.png';

  @override
  Widget build(BuildContext context) {
    final avatarSize = MediaQuery.of(context).size.width * 0.58;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              children: [
                // Baris atas: tombol kembali & tombol notifikasi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleBackButton(),
                    _buildNotifButton(context),
                  ],
                ),
                const SizedBox(height: 24),
                // Foto profil bulat
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const AssetImageBox(path: _avatar),
                ),
                const SizedBox(height: 20),
                Text(
                  'Rangga Pratama',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Pengunjung',
                  style: GoogleFonts.plusJakartaSans(fontSize: 20),
                ),
                const SizedBox(height: 28),
                DarkButton(text: 'FaQ', onPressed: () {}),
                const SizedBox(height: 16),
                                DarkButton(
                  text: 'Tanya AI',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                DarkButton(
                  text: 'LOGOUT',
                  width: 130,
                  height: 46,
                  fontSize: 16,
                  radius: 20,
                  onPressed: () {
                    // Hapus semua halaman sebelumnya, kembali ke Login
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tombol notifikasi hijau tua 3D + angka badge merah -> halaman Notifikasi
  Widget _buildNotifButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NotificationScreen()),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 66,
            padding: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [AppColors.darkGreen, AppColors.midGreen],
                ),
              ),
              child: const Icon(Icons.notifications_none, color: Colors.white),
            ),
          ),
          Positioned(
            top: -10,
            right: -2,
            child: Text(
              '1',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}