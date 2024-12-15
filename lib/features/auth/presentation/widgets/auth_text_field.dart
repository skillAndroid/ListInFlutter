import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothClipRRect(
      smoothness: 1,
      borderRadius: BorderRadius.circular(12),
      child: TextFormField(
        style: const TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        cursorColor: AppColors.black,
        controller: controller,
        decoration: InputDecoration(
          hintText: labelText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
//