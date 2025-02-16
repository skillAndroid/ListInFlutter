import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/services/auth_service.dart';
import 'package:list_in/features/visitior_profile/data/model/another_user_profile_model.dart';
import 'package:list_in/features/visitior_profile/data/model/another_user_publications_model.dart';

abstract class AnotherUserProfileRemoute {
  Future<AnotherUserProfileModel> getUserData(String? userId);
  Future<AnotherUserPublicationsModel> getPublications({
    int? page,
    int? size,
    String userId,
  });
  Future<AnotherUserProfileModel> followUser(String userId, bool follow);
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
      final response = await dio.get(
        '/api/v1/user/$userId',
        options: options,
      );

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

  @override
  Future<AnotherUserPublicationsModel> getPublications({
    int? page,
    int? size,
    String? userId,
  }) async {
    final options = await authService.getAuthOptions();
    final response = await dio.get(
      '/api/v1/publications/user/$userId',
      queryParameters: {
        'page': page,
        'size': size,
      },
      options: options,
    );

    debugPrint("❤️❤️ ${response.data}");

    if (response.data == null) {
      throw ServerExeption(message: 'Null response data');
    }
    try {
      return AnotherUserPublicationsModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ConnectiontTimeOutExeption();
      } else if (e.type == DioExceptionType.unknown) {
        throw ConnectionExeption(message: 'Connection failed');
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access');
      } else {
        throw ServerExeption(message: e.message.toString());
      }
    } catch (e, stackTrace) {
      debugPrint('Unexpected error in remote data source: $e');
      debugPrint('Stack trace: $stackTrace');
      throw ServerExeption(message: e.toString());
    }
  }

  @override
  Future<AnotherUserProfileModel> followUser(String userId, bool follow) async {
    final options = await authService.getAuthOptions();

    try {
      final response = await dio.get(
        follow
            ? '/api/v1/user/follow/$userId'
            : '/api/v1/user/unfollow/$userId',
        options: options,
      );
      if (response.statusCode == 200) {
        // Convert the response data to AnotherUserProfileModel and then to entity
        final profileModel = AnotherUserProfileModel.fromJson(response.data);
        return profileModel;
      } else {
        throw ServerExeption(message: 'Failed to follow user');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ConnectiontTimeOutExeption();
      }
      throw ServerExeption(message: e.message ?? 'Unknown error occurred');
    }
  }
}
