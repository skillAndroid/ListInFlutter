import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/services/auth_service.dart';
import 'package:list_in/features/followers/data/models/user_follow_followers_data_model.dart';

abstract class UserSocialRemoteDataSource {
  Future<PaginatedResponseModel<UserProfileModel>> getFollowings(String userId,
      {int page = 0, int size = 5});
  Future<PaginatedResponseModel<UserProfileModel>> getFollowers(String userId,
      {int page = 0, int size = 5});
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
      {int page = 0, int size = 5}) async {
    final options = await authService.getAuthOptions();
    String url = '/api/v1/user/followings/$userId';

    try {
      final response = await dio.get(
        url,
        options: options,
      );
      if (response.statusCode == 200) {
        return PaginatedResponseModel<UserProfileModel>.fromJson(
          json.decode(response.data),
          (json) => UserProfileModel.fromJson(json),
        );
      } else {
        throw ServerExeption(message: 'Failed to get user data');
      }
    } catch (e) {
      throw ServerExeption(message: 'Failed to get user data');
    }
  }

  @override
  Future<PaginatedResponseModel<UserProfileModel>> getFollowers(String userId,
      {int page = 0, int size = 5}) async {
    final options = await authService.getAuthOptions();
    String url = '/api/v1/user/follow/$userId';

    try {
      final response = await dio.get(
        url,
        options: options,
      );
      if (response.statusCode == 200) {
        return PaginatedResponseModel<UserProfileModel>.fromJson(
          json.decode(response.data),
          (json) => UserProfileModel.fromJson(json),
        );
      } else {
        throw ServerExeption(message: 'Failed to get user data');
      }
    } catch (e) {
      throw ServerExeption(message: 'Failed to get user data');
    }
  }
}
