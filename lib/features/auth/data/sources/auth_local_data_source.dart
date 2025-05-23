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
  Future<void> cacheUserId(String? userId);
  Future<String?> getUserId();
  Future<void> cacheProfileImagePath(String? profileImagePath);
  Future<String?> getProfileImagePath();
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
    final jsonString =
        sharedPreferences.getString(Constants.CACHED_RETRIVED_EMAIL);
    if (jsonString != null) {
      return RetrivedEmailModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> cacheUserId(String? userId) async {
    if (userId == null) {
      await sharedPreferences.remove(Constants.CACHED_USER_ID);
    } else {
      await sharedPreferences.setString(Constants.CACHED_USER_ID, userId);
    }
  }

  @override
  Future<String?> getUserId() async {
    return sharedPreferences.getString(Constants.CACHED_USER_ID);
  }

  // Implementation of new methods for profile image
  @override
  Future<void> cacheProfileImagePath(String? profileImagePath) async {
    if (profileImagePath == null) {
      await sharedPreferences.remove(Constants.CACHED_PROFILE_IMAGE_PATH);
    } else {
      await sharedPreferences.setString(
          Constants.CACHED_PROFILE_IMAGE_PATH, profileImagePath);
    }
  }

  @override
  Future<String?> getProfileImagePath() async {
    return sharedPreferences.getString(Constants.CACHED_PROFILE_IMAGE_PATH);
  }
}
