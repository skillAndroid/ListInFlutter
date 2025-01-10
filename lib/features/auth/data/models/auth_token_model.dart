import 'package:list_in/features/auth/domain/entities/auth_tokens.dart';

class AuthTokenModel extends AuthToken {
  AuthTokenModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  // Add this method
  AuthToken toEntity() {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
