import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/circle_back_button.dart';
import '../../shared/widgets/gradient_background.dart';
import '../../shared/widgets/gradient_button.dart';
import '../home/home_screen.dart';
import 'auth_field.dart';
import 'auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  String? _error;
  String? _nameError;
  String? _emailError;
  String? _passError;
  String? _confirmError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _email.text.trim();
    String? nameError;
    String? emailError;
    String? passwordError;
    String? confirmError;

    if (_name.text.trim().isEmpty) {
      nameError = 'Nama lengkap wajib diisi';
    }

    if (email.isEmpty) {
      emailError = 'Email wajib diisi';
    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      emailError = 'Format email tidak valid';
    }

    if (_password.text.isEmpty) {
      passwordError = 'Kata sandi wajib diisi';
    }

    if (_confirm.text != _password.text) {
      confirmError = 'Konfirmasi tidak sama dengan password';
    }

    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _passError = passwordError;
      _confirmError = confirmError;
      _error = null;
    });

    return nameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmError == null;
  }

  Future<void> _submit() async {
    if (_loading || !_validate()) return;

    setState(() => _loading = true);

    try {
      await AuthService.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );

      // Setelah daftar, langsung masuk.
      await AuthService.login(_email.text.trim(), _password.text);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.message;
        _nameError = e.fieldErrors['name'];
        _emailError = e.fieldErrors['email'];
        _passError = e.fieldErrors['password'];
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Terjadi kesalahan. Coba lagi.';
      });
    }
  }

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
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
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
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECEA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD32F2F)),
                    ),
                    child: Text(
                      _error!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFFB71C1C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                AuthField(
                  label: 'Nama Lengkap',
                  hint: 'Masukan nama Anda',
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  errorText: _nameError,
                ),
                const SizedBox(height: 20),
                AuthField(
                  label: 'Email',
                  hint: 'Masukan email anda',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  errorText: _emailError,
                ),
                const SizedBox(height: 20),
                AuthField(
                  label: 'Password',
                  hint: 'Masukan password',
                  controller: _password,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  errorText: _passError,
                ),
                const SizedBox(height: 20),
                AuthField(
                  label: 'Konfirmasi password',
                  hint: 'Konfirmasi password Anda',
                  controller: _confirm,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  errorText: _confirmError,
                ),
                const SizedBox(height: 32),
                GradientButton(
                  text: _loading ? 'Memproses...' : 'Daftar Akun',
                  onPressed: _loading ? () {} : _submit,
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
