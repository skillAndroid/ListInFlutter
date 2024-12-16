import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    appBarTheme: const AppBarTheme(
      elevation: 0,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.black,
      selectionColor: AppColors.lightGray,
      selectionHandleColor: AppColors.black,
    ),
    secondaryHeaderColor: AppColors.secondaryColor,
    scaffoldBackgroundColor: AppColors.lightBackground,
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      hintStyle: const TextStyle(
        color: AppColors.gray,
        fontWeight: FontWeight.w400,
      ),
      fillColor: AppColors.bgColor,
      contentPadding: const EdgeInsets.all(30),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.transparent,
          width: 0,
        ),
      ),
      errorStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.transparent,
          width: 0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.transparent,
          width: 0,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.containerColor,
        foregroundColor: AppColors.black,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        shape: SmoothRectangleBorder(
          smoothness: 1,
          borderRadius: BorderRadius.circular(18),
        ),
      ).copyWith(
        elevation: WidgetStateProperty.resolveWith((states) {
          return 0;
        }),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: SmoothRectangleBorder(
          smoothness: 1,
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    brightness: Brightness.dark,
    fontFamily: 'Satoshi',
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      hintStyle: const TextStyle(
          color: Color(0xffa7a7a7), fontWeight: FontWeight.w500),
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.all(30),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white, width: 0.4)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.white, width: 0.4),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white, // This sets the text color
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        elevation: 0,
        shape: SmoothRectangleBorder(
          smoothness: 1,
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );

  static void setStatusBarAndNavBarColor(ThemeData theme) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }
}
