import 'package:list_in/config/theme/app_language.dart';
import 'package:list_in/core/local_data/shared_preferences.dart';

class LanguageRepository {
  final SharedPrefsService prefsService;
  
  LanguageRepository({required this.prefsService});
  
  Future<void> setLanguage(String languageCode) async {
    await prefsService.saveString(AppLanguages.languageCodeKey, languageCode);
  }
  
  String getLanguage() {
    return prefsService.getString(AppLanguages.languageCodeKey) ?? AppLanguages.english;
  }
}
