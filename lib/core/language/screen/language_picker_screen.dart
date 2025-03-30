// ignore_for_file: deprecated_member_use

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/config/theme/app_language.dart';
import 'package:list_in/core/language/language_bloc.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shadowColor: AppColors.transparent,
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          AppLocalizations.of(context)!.language,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: ListView(
          children: AppLanguages.supportedLocales.map((locale) {
            final languageCode = locale.languageCode;
            final languageName =
                AppLanguages.languageNames[languageCode] ?? languageCode;

            // Get flag emoji for the specific languages
            String flag = '🌐';
            if (languageCode == 'en') flag = '🇺🇸'; // English
            if (languageCode == 'uz') flag = '🇺🇿'; // Uzbek
            if (languageCode == 'ru') flag = '🇷🇺'; // Russian

            return BlocBuilder<LanguageBloc, LanguageState>(
              builder: (context, state) {
                final isSelected = state is LanguageLoaded &&
                    state.languageCode == languageCode;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Container(
                    decoration: ShapeDecoration(
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 16,
                          cornerSmoothing: 0.7,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : Theme.of(context).cardColor,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context.read<LanguageBloc>().add(
                              ChangeLanguageEvent(languageCode: languageCode));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 20.0),
                          child: Row(
                            children: [
                              Text(
                                flag,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  languageName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
