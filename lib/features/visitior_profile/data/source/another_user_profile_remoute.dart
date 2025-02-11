import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/services/auth_service.dart';
import 'package:list_in/features/visitior_profile/data/model/another_user_profile_model.dart';

abstract class AnotherUserProfileRemoute {
  Future<AnotherUserProfileModel> getUserData(String? userId);
}

class AnotherUserProfileRemouteImpl implements AnotherUserProfileRemoute {
  final Dio dio;
  final AuthService authService;

  AnotherUserProfileRemouteImpl({
    required this.dio,
    required this.authService,
  });

  @override
  Future<AnotherUserProfileModel> getUserData(String? userId) async {
    final options = await authService.getAuthOptions();

    try {
      final response =
          await dio.get('/api/v1/user', options: options, queryParameters: {
        'userId': userId,
      });

      debugPrint("🎯 response data : ${response.data} ");

      if (response.statusCode == 200) {
        return AnotherUserProfileModel.fromJson(response.data);
      } else {
        throw ServerExeption(message: 'Failed to get user data');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          throw ConnectiontTimeOutExeption();
        }
        throw ServerExeption(message: e.message ?? 'Unknown error occurred');
      }
      throw ServerExeption(message: 'Failed to get user data');
    }
  }
}
