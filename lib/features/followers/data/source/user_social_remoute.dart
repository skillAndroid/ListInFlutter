import 'package:dio/dio.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/services/auth_service.dart';
import 'package:list_in/features/followers/data/models/user_follow_followers_data_model.dart';

abstract class UserSocialRemoteDataSource {
  Future<PaginatedResponseModel<UserProfileModel>> getFollowings(String userId,
      {int page = 0, int size = 30});
  Future<PaginatedResponseModel<UserProfileModel>> getFollowers(String userId,
      {int page = 0, int size = 30});
}

class UserSocialRemoteDataSourceImpl implements UserSocialRemoteDataSource {
  final Dio dio;
  final AuthService authService;

  UserSocialRemoteDataSourceImpl({
    required this.dio,
    required this.authService,
  });

  @override
  Future<PaginatedResponseModel<UserProfileModel>> getFollowings(String userId,
      {int page = 0, int size = 30}) async {
    final options = await authService.getAuthOptions();
    String url = '/api/v1/user/followings/$userId';
    print(
        '📡 Requesting followings for user: $userId, page: $page, size: $size');
    try {
      final response = await dio.get(
        url,
        options: options,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      if (response.statusCode == 200) {
        print('✅ Successfully fetched followings for user: $userId');
        // Fix: No need to decode response.data as it's already a Map
        return PaginatedResponseModel<UserProfileModel>.fromJson(
          response.data, // Changed from json.decode(response.data)
          (json) => UserProfileModel.fromJson(json),
        );
      } else {
        print(
            '❌ Failed to fetch followings for user: $userId, Status Code: ${response.statusCode}');
        throw ServerExeption(message: 'Failed to get user data');
      }
    } catch (e) {
      print('❌ Error fetching followings for user: $userId - $e');
      throw ServerExeption(message: 'Failed to get user data');
    }
  }

  @override
  Future<PaginatedResponseModel<UserProfileModel>> getFollowers(String userId,
      {int page = 0, int size = 30}) async {
    final options = await authService.getAuthOptions();
    String url = '/api/v1/user/followers/$userId';
    print(
        '📡 Requesting followers for user: $userId, page: $page, size: $size');
    try {
      final response = await dio.get(
        url,
        options: options,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      if (response.statusCode == 200) {
        print('✅ Successfully fetched followers for user: $userId');
        // Fix: No need to decode response.data as it's already a Map
        return PaginatedResponseModel<UserProfileModel>.fromJson(
          response.data, // Changed from json.decode(response.data)
          (json) => UserProfileModel.fromJson(json),
        );
      } else {
        print(
            '❌ Failed to fetch followers for user: $userId, Status Code: ${response.statusCode}');
        throw ServerExeption(message: 'Failed to get user data');
      }
    } catch (e) {
      print('❌ Error fetching followers for user: $userId - $e');
      throw ServerExeption(message: 'Failed to get user data');
    }
  }
}
