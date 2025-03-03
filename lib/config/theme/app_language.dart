import 'package:flutter/material.dart';
class AppLanguages {
  static const String english = 'en';
  static const String russian = 'ru';
  static const String uzbek = 'uz';

  static const String languageCodeKey = 'languageCode';
  
  static const List<Locale> supportedLocales = [
    Locale(english),
    Locale(russian),
    Locale(uzbek),
  ];
  
  static const Map<String, String> languageNames = {
    english: 'English',
    russian: 'Русский',
    uzbek: 'O\'zbek',
  };
}