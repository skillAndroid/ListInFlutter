import 'package:shared_preferences/shared_preferences.dart';

Future<String> getCurrentLanguageFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('languageCode') ?? 'en';
}