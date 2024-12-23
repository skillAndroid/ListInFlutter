
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  final SharedPreferences _sharedPreferences;

  SharedPrefsService(SharedPreferences preferences) : _sharedPreferences = preferences;

  Future<void> saveString(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }

  String? getString(String key) {
    return _sharedPreferences.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _sharedPreferences.setBool(key, value);
  }

  Future<void> saveInt(String key, int value) async {
    await _sharedPreferences.setInt(key, value);
  }

  bool? getBool(String key) {
    return _sharedPreferences.getBool(key);
  }

  int? getInt(String key) {
    return _sharedPreferences.getInt(key);
  }

  Future<void> delete(String key) async {
    await _sharedPreferences.remove(key);
  }
}