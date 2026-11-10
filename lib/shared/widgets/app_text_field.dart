import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hidden = true;

  OutlineInputBorder _border({double width = 1.5}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.primary, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16, color: AppColors.grey)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.isPassword && _hidden,
            style: GoogleFonts.plusJakartaSans(fontSize: 16),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              enabledBorder: _border(),
              focusedBorder: _border(width: 2),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _hidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.grey,
                      ),
                      onPressed: () => setState(() => _hidden = !_hidden),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}