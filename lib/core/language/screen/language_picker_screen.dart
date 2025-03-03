import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:list_in/config/theme/app_language.dart';
import 'package:list_in/core/language/language_bloc.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.language),
      ),
      body: ListView(
        children: AppLanguages.supportedLocales.map((locale) {
          final languageCode = locale.languageCode;
          final languageName = AppLanguages.languageNames[languageCode] ?? languageCode;
          
          return BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, state) {
              final isSelected = state is LanguageLoaded && state.languageCode == languageCode;
              
              return ListTile(
                title: Text(languageName),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () {
                  context.read<LanguageBloc>().add(ChangeLanguageEvent(languageCode: languageCode));
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }
}