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
      side: BorderSide(width: 1, color: AppColors.containerColor),
      borderRadius: BorderRadius.circular(16),
      child: TextFormField(
        style: const TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        cursorColor: AppColors.black,
        cursorRadius: Radius.circular(2),
        cursorErrorColor: AppColors.black,
        controller: controller,
        decoration: InputDecoration(
          labelStyle: TextStyle(color: AppColors.darkGray),
          helperStyle: TextStyle(color: AppColors.darkGray),
          fillColor: AppColors.bgColor,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          hintText: labelText,
          errorStyle: TextStyle(
            color: Colors.red,
            fontSize: 11,
            height: 1.5, // This reduces the vertical spacing
          ),
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
