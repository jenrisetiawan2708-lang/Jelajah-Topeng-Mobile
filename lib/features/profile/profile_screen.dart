import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/asset_image_box.dart';
import '../../shared/widgets/dark_button.dart';
import '../../shared/widgets/gradient_background.dart';
import '../auth/auth_service.dart';
import '../auth/login_screen.dart';
import '../chat/chat_screen.dart';
import '../exploration/exploration_screen.dart';
import '../faq/faq_screen.dart';
import '../game/game_progress.dart';
import '../notification/notification_screen.dart';
import '../progress/progress_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.showBack = false});

  /// true kalau halaman ini dibuka lewat push (bukan sebagai tab).
  final bool showBack;

  static const _avatar = 'assets/images/avatar.png';
  static const _ink = Color(0xFF1E2B12);
  static const _sub = Color(0xFF6B7F5A);
  static const _lime = Color(0xFFB8F08C);
  static const _red = Color(0xFFE0453A);
  static const _totalLevels = 5;
  static const _notifCount = 1;

  TextStyle _t(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = _ink,
    double? height,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Keluar dari akun?',
          style: _t(18, weight: FontWeight.w800),
        ),
        content: Text(
          'Kamu perlu login lagi untuk melanjutkan petualangan.',
          style: _t(14, color: _sub, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Batal',
              style: _t(14, weight: FontWeight.w700, color: _sub),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Keluar',
              style: _t(14, weight: FontWeight.w800, color: _red),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await AuthService.logout();
    if (!context.mounted) return;
    // Hapus semua halaman sebelumnya, kembali ke Login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.current;
    final name = (user?.name.isNotEmpty == true) ? user!.name : 'Sobat Budaya';
    final email = user?.email ?? '';
    final width = MediaQuery.of(context).size.width;
    final avatarSize = (width * 0.34).clamp(110.0, 150.0);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 130),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 22),

                // Foto profil
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppColors.primary, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const ClipOval(child: AssetImageBox(path: _avatar)),
                ),
                const SizedBox(height: 16),

                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _t(24, weight: FontWeight.w800),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(email, style: _t(13, color: _sub)),
                ],
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pengunjung',
                    style: _t(
                      12.5,
                      weight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Kartu progres (dibuka -> halaman Progres Budaya)
                ValueListenableBuilder<int>(
                  valueListenable: GameProgress.completed,
                  builder: (_, c, _) {
                    final done = c.clamp(0, _totalLevels);
                    return _buildProgressCard(context, done);
                  },
                ),
                const SizedBox(height: 16),

                // Daftar menu
                _buildMenu(context),
                const SizedBox(height: 22),

                DarkButton(
                  text: 'LOGOUT',
                  width: 150,
                  height: 46,
                  fontSize: 15,
                  radius: 20,
                  onPressed: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ header
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (showBack) ...[
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.75),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                size: 30,
                color: _ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text('Profil', style: _t(26, weight: FontWeight.w800)),
        ),
        // Tombol Eksplorasi Kampung: lingkaran hijau tua 3D + ikon peta.
        Semantics(
          button: true,
          label: 'Eksplorasi Kampung',
          child: GestureDetector(
            onTap: () => _push(context, const ExplorationScreen()),
            child: SizedBox(
              width: 56,
              height: 62,
              child: Stack(
                children: [
                  // "Bibir" hijau muda di bawah lingkaran.
                  Positioned(
                    top: 6,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Lingkaran hijau tua dengan ikon peta putih.
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.darkGreen, AppColors.midGreen],
                      ),
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------- kartu progres
  Widget _buildProgressCard(BuildContext context, int done) {
    return GestureDetector(
      onTap: () => _push(context, const ProgressScreen()),
      child: Container(
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.darkGreen, AppColors.midGreen],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flag_rounded, color: _lime, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progres Budaya',
                      style: _t(
                        15,
                        weight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$done dari $_totalLevels level selesai',
                      style: _t(12, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: done / _totalLevels),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, _) => LinearProgressIndicator(
                          value: v,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation(_lime),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------- menu
  Widget _buildMenu(BuildContext context) {
    final divider = Divider(
      height: 1,
      indent: 70,
      endIndent: 16,
      color: Colors.black.withValues(alpha: 0.07),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              _tile(
                icon: Icons.help_outline_rounded,
                title: 'FAQ',
                subtitle: 'Pertanyaan yang sering diajukan',
                onTap: () => _push(context, const FaqScreen()),
              ),
              divider,
              _tile(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Tanya AI',
                subtitle: 'Tanya seputar Kampung Budaya',
                onTap: () => _push(context, const ChatScreen()),
              ),
              divider,
              _tile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifikasi',
                subtitle: _notifCount > 0
                    ? '$_notifCount pesan baru'
                    : 'Tidak ada pesan baru',
                onTap: () => _push(context, const NotificationScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.darkGreen, AppColors.midGreen],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.55),
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _t(15, weight: FontWeight.w700)),
                  const SizedBox(height: 1),
                  Text(subtitle, style: _t(12, color: _sub)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _sub, size: 24),
          ],
        ),
      ),
    );
  }
}
