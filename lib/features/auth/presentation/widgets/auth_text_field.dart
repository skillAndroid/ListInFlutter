import 'package:flutter/material.dart';
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
      side: BorderSide(
        width: 1,
        color: Theme.of(context).cardColor,
      ),
      borderRadius: BorderRadius.circular(16),
      child: TextFormField(
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        cursorColor: Theme.of(context).colorScheme.secondary,
        cursorRadius: Radius.circular(2),
        cursorErrorColor: Theme.of(context).colorScheme.secondary,
        controller: controller,
        decoration: InputDecoration(
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          helperStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          fillColor: Theme.of(context).scaffoldBackgroundColor,
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
