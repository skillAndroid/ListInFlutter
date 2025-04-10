import 'package:flutter/material.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const SearchTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
          icon: Padding(
            padding: const EdgeInsets.only(
              left: 12,
              top: 12,
              bottom: 12,
            ),
            child: Image.asset(
              width: 24,
              height: 24,
              AppIcons.searchIcon,
            ),
          ),
          suffixIcon: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Map',
              style: TextStyle(
                fontFamily: Constants.Arial,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primary,
              ),
            ),
          ),
          fillColor: AppColors.white,
          hintText: labelText,
          hintStyle: TextStyle(
            color: Colors.grey,
            fontFamily: Constants.Arial,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          contentPadding: const EdgeInsets.only(
            right: 16,
            bottom: 20,
          ),
        ),
        cursorHeight: 16,
        cursorRadius: Radius.circular(2),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}
//
