import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: TextFormField(
        style: const TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        cursorColor: AppColors.black,
        cursorRadius: Radius.circular(2),
        controller: controller,
        decoration: InputDecoration(
          labelStyle: TextStyle(color: AppColors.darkGray),
          helperStyle: TextStyle(color: AppColors.darkGray),
          fillColor: AppColors.bgColor,
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
