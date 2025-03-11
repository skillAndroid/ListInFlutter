import 'package:list_in/config/theme/app_language.dart';

class LocalizationCache {
  final Map<String, String> _cache = {};
  final String _languageCode;
  
  LocalizationCache(this._languageCode);
  
  String getText(String? defaultText, String? uzText, String? ruText) {
    // Create a unique key for this text combination
    final key = '$defaultText|${uzText ?? ''}|${ruText ?? ''}|$_languageCode';
    
    // Return cached value if available
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    
    // Calculate and cache the value
    String result;
    if (_languageCode == AppLanguages.uzbek && uzText != null) {
      result = uzText;
    } else if (_languageCode == AppLanguages.russian && ruText != null) {
      result = ruText;
    } else {
      result = defaultText ?? '';
    }
    
    _cache[key] = result;
    return result;
  }
}