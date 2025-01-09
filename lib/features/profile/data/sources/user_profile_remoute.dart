import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/services/auth_service.dart';
import 'package:list_in/features/auth/data/models/auth_token_model.dart';
import 'package:list_in/features/profile/data/model/user_data_model.dart';
import 'package:list_in/features/profile/data/model/user_profile_model.dart';

abstract class UserProfileRemoute {
  Future<List<String>> uploadImages(List<XFile> images);
  Future<AuthTokenModel> updateUserData(UserProfileModel user);
  Future<UserDataModel> getUserData();
}

class UserProfileRemouteImpl implements UserProfileRemoute {
  final Dio dio;
  final AuthService authService;

  UserProfileRemouteImpl({
    required this.dio,
    required this.authService,
  });

  @override
  Future<List<String>> uploadImages(List<XFile> images) async {
    final options = await authService.getAuthOptions();

    try {
      final formData = FormData();
      for (var i = 0; i < images.length; i++) {
        final file = await MultipartFile.fromFile(
          images[i].path,
          filename: images[i].name,
        );
        formData.files.add(MapEntry('images', file));
      }

      final response = await dio.post(
        '/api/v1/files/upload/images',
        data: formData,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return List<String>.from(response.data);
      } else {
        throw ServerExeption(message: 'Failed to upload images');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          throw ConnectiontTimeOutExeption();
        }
        throw ServerExeption(message: e.message ?? 'Unknown error occurred');
      }
      throw ServerExeption(message: 'Failed to upload images');
    }
  }

  @override
  Future<AuthTokenModel> updateUserData(UserProfileModel user) async {
    final options = await authService.getAuthOptions();
    try {
      debugPrint("🔄${user.nickName}");
      debugPrint("🔄${user.phoneNumber}");
      debugPrint("🔄${user.isBusinessAccount}");
      debugPrint("🔄${user.isGrantedForPreciseLocation}");
      debugPrint("🔄${user.profileImagePath}");
      debugPrint("🔄${user.toTime}");
      debugPrint("🔄${user.fromTime}");
      debugPrint("🔄${user.locationName}");
      debugPrint("🔄${user.longitude}");
      debugPrint("🔄${user.latitude}");
      
      final response = await dio.patch('/api/v1/user/update',
          data: user.toJson(), options: options);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthTokenModel.fromJson(response.data);
      } else {
        throw ServerExeption(message: 'Failed to update user data');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserDataModel> getUserData() async {
    final options = await authService.getAuthOptions();

    try {
      final response = await dio.get(
        '/api/v1/user',
        options: options,
      );

      debugPrint("🎯 response data : ${response.data} ");

      if (response.statusCode == 200) {
        return UserDataModel.fromJson(response.data);
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
