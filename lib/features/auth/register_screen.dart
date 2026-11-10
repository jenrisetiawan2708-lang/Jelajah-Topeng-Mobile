import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/circle_back_button.dart';
import '../../shared/widgets/gradient_background.dart';
import '../../shared/widgets/gradient_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        colors: const [AppColors.bgTop, Colors.white],
        stops: const [0.0, 0.5],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: CircleBackButton(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Buat Akun Baru',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 34, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.plusJakartaSans(fontSize: 17),
                    children: const [
                      TextSpan(text: 'Yuk Gabung dan mulai '),
                      TextSpan(
                        text: 'Jelajahi sekarang!',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                const AppTextField(
                    label: 'Nama Lengkap', hint: 'Masukan nama Anda'),
                const SizedBox(height: 20),
                const AppTextField(
                  label: 'Email',
                  hint: 'Masukan email anda',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                const AppTextField(
                  label: 'Password',
                  hint: 'Masukan password',
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                const AppTextField(
                  label: 'Konfirmasi password',
                  hint: 'Konfirmasi password Anda',
                  isPassword: true,
                ),
                const SizedBox(height: 40),
                GradientButton(
                  text: 'Daftar Akun',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Login',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}