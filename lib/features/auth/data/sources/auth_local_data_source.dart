import 'dart:convert';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/auth/data/models/auth_token_model.dart';
import 'package:list_in/features/auth/data/models/retrived_email_model.dart';
import 'package:list_in/features/auth/domain/entities/retrived_email.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthToken(AuthTokenModel authToken);
  Future<AuthTokenModel?> getLastAuthToken();
  Future<void> clearAuthToken();

  Future<void> cacheRetrivedEmail(RetrivedEmailModel retrivedEmail);
  Future<RetrivedEmail?> getRetrivedEmail();
  Future<void> deleteRetrivedEmail();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheAuthToken(AuthTokenModel authToken) async {
    await sharedPreferences.setString(
        Constants.CACHED_AUTH_TOKEN, json.encode(authToken.toJson()));
  }

  @override
  Future<AuthTokenModel?> getLastAuthToken() async {
    final jsonString = sharedPreferences.getString(Constants.CACHED_AUTH_TOKEN);
    if (jsonString != null) {
      return AuthTokenModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> clearAuthToken() async {
    await sharedPreferences.remove(Constants.CACHED_AUTH_TOKEN);
  }

  @override
  Future<void> cacheRetrivedEmail(RetrivedEmailModel retrivedEmail) async {
    await sharedPreferences.setString(
        Constants.CACHED_RETRIVED_EMAIL, json.encode(retrivedEmail.toJson()));
  }

  @override
  Future<void> deleteRetrivedEmail() async {
    await sharedPreferences.remove(Constants.CACHED_RETRIVED_EMAIL);
  }

  @override
  Future<RetrivedEmail?> getRetrivedEmail() async {
    final jsonString = sharedPreferences.getString(Constants.CACHED_RETRIVED_EMAIL);
    if (jsonString != null) {
      return RetrivedEmailModel.fromJson(json.decode(jsonString));
    }
    return null;
  }
}
