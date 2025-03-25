import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    cardColor: AppColors.containerColor,
    appBarTheme: const AppBarTheme(
      elevation: 0,
    ),
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.primary,
      secondary: AppColors.black,
      onSecondary: AppColors.containerColor,
      error: AppColors.error,
      onError: AppColors.error,
      surface: AppColors.darkGray,
      onSurface: AppColors.darkBackground,
    ),
    highlightColor: AppColors.containerColor,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.black,
      selectionColor: AppColors.lightGray,
      selectionHandleColor: AppColors.black,
    ),
    secondaryHeaderColor: AppColors.secondaryColor,
    scaffoldBackgroundColor: AppColors.white,
    brightness: Brightness.light,
    fontFamily: Constants.Arial,
    textTheme: Typography.material2018().black.copyWith(
          bodyLarge: const TextStyle(
            color: AppColors.black,
            fontSize: 17,
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: const TextStyle(
            color: AppColors.darkGray,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          titleLarge: const TextStyle(
            color: AppColors.black,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      hintStyle: const TextStyle(
        color: AppColors.grey,
        fontWeight: FontWeight.w400,
      ),
      fillColor: AppColors.containerColor,
      contentPadding: const EdgeInsets.all(30),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.transparent,
          width: 0,
        ),
      ),
      errorStyle: const TextStyle(
        fontFamily: Constants.Arial,
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
        shape: RoundedRectangleBorder(
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
        shape: RoundedRectangleBorder(
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
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.primary,
      secondary: AppColors.white,
      onSecondary: AppColors.containerColorDark,
      error: AppColors.error,
      onError: AppColors.error,
      surface: AppColors.lightGray,
      onSurface: AppColors.lightBackground,
    ),
    primaryColor: AppColors.primary,
    highlightColor: AppColors.containerColorDark2,
    cardColor: AppColors.containerColorDark,
    scaffoldBackgroundColor: AppColors.black,
    brightness: Brightness.dark,
    fontFamily: Constants.Arial,
    textTheme: Typography.material2018().black.copyWith(
          bodyLarge: const TextStyle(
            color: AppColors.white,
            fontSize: 17,
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: const TextStyle(
            color: AppColors.lightGray,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          titleLarge: const TextStyle(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
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
        foregroundColor: AppColors.white,
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
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
        systemNavigationBarColor: AppColors.transparent,
      ),
    );
  }

  // Add this method to your app's main.dart to disable system text scaling
  static void disableSystemTextScaling() {
    // This ensures the app ignores the system text scale factor
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    // Disable system text scaling
    MediaQueryData.fromView(
            WidgetsBinding.instance.platformDispatcher.views.first)
        .copyWith(textScaler: TextScaler.linear(0.85));
  }
}
