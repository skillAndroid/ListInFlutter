// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthValidators {
  static String? validateName(BuildContext context, String? value) {
    final localizations = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return localizations.nameEmpty;
    }
    return null;
  }

  static String? validatePassword(BuildContext context, String? value) {
    final localizations = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return localizations.password_empty;
    }
    if (value.length < 6) {
      return localizations.passwordMinLength;
    }
    return null;
  }

  static String? validatePhoneNumber(BuildContext context, String? value) {
    final localizations = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return localizations.phone_number_empty;
    }
    // Add phone number format validation if needed
    return null;
  }
}

// For option cards with localized text
class OptionCard extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String description;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.isSelected,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected
            ? Theme.of(context).colorScheme.secondary.withOpacity(0.25)
            : Theme.of(context).cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 21 : 20,
                height: isSelected ? 21 : 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey,
                    width: isSelected ? 5 : 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper class for localized options based on language
class LocalizedOptions {
  static List<Map<String, String>> getOptions(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return [
      {
        'title': localizations.sellPersonalItems,
        'description': localizations.sellPersonalItemsDesc,
      },
      {
        'title': localizations.createStore,
        'description': localizations.createStoreDesc,
      },
    ];
  }

  // Fallback options in case localization is not available
  static List<Map<String, String>> getFallbackOptions(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return [
          {
            'title': 'Обычный пользователь',
            'description': 'Покупайте и продавайте товары легко и удобно.',
          },
          {
            'title': 'Платформа для бизнеса',
            'description':
                'Создайте бизнес для продажи, аренды товаров или предоставления услуг.',
          },
        ];
      case 'uz':
        return [
          {
            'title': 'Oddiy foydalanuvchi',
            'description': 'Mahsulotlarni oson sotib oling yoki soting.',
          },
          {
            'title': 'Biznes platformasi',
            'description':
                'Savdo, ijaraga berish va xizmatlar uchun biznes yarating.',
          },
        ];
      default: // English
        return [
          {
            'title': 'Simple User',
            'description': 'Easily buy and sell items as an individual.',
          },
          {
            'title': 'Business Platform',
            'description':
                'Create a business for selling, renting, or offering services.',
          },
        ];
    }
  }
}

// For fallback validation messages
class ValidationMessages {
  static Map<String, Map<String, String>> messages = {
    'en': {
      'nameEmpty': 'Please enter your name',
      'passwordEmpty': 'Please enter a password',
      'passwordMinLength': 'Password must be at least 6 characters',
      'phoneNumberEmpty': 'Please enter your phone number',
    },
    'ru': {
      'nameEmpty': 'Пожалуйста, введите ваше имя',
      'passwordEmpty': 'Пожалуйста, введите пароль',
      'passwordMinLength': 'Пароль должен содержать не менее 6 символов',
      'phoneNumberEmpty': 'Пожалуйста, введите ваш номер телефона',
    },
    'uz': {
      'nameEmpty': 'Iltimos, ismingizni kiriting',
      'passwordEmpty': 'Iltimos, parol kiriting',
      'passwordMinLength': 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak',
      'phoneNumberEmpty': 'Iltimos, telefon raqamingizni kiriting',
    },
  };

  static String getMessage(BuildContext context, String key) {
    final locale = Localizations.localeOf(context);
    final langCode = locale.languageCode;

    // Try to get from AppLocalizations first
    final localizations = AppLocalizations.of(context);
    if (localizations != null) {
      switch (key) {
        case 'nameEmpty':
          return localizations.nameEmpty;
        case 'passwordEmpty':
          return localizations.password_empty;
        case 'passwordMinLength':
          return localizations.passwordMinLength;
        case 'phoneNumberEmpty':
          return localizations.phone_number_empty;
      }
    }

    // Fallback to hardcoded messages
    final langMessages = messages[langCode] ?? messages['en']!;
    return langMessages[key] ?? messages['en']![key]!;
  }
}
