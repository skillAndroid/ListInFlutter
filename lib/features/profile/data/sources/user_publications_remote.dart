import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/services/auth_service.dart';
import 'package:list_in/features/profile/data/model/publication/paginated_publications_model.dart';
import 'package:list_in/features/profile/data/model/publication/update_user_post_model.dart';

abstract class UserPublicationsRemoteDataSource {
  Future<PaginatedPublicationsModel> getUserPublications({
    required int page,
    required int size,
  });
  Future<PaginatedPublicationsModel> getUserLikedPublications({
    required int page,
    required int size,
  });

  Future<void> updatePublication(UpdatePostModel publication, String id);
  Future<void> deletePublication(String id);
}

class UserPublicationsRemoteDataSourceImpl
    implements UserPublicationsRemoteDataSource {
  final Dio dio;
  final AuthService authService;

  UserPublicationsRemoteDataSourceImpl({
    required this.dio,
    required this.authService,
  });

  @override
  Future<PaginatedPublicationsModel> getUserPublications({
    required int page,
    required int size,
  }) async {
    try {
      final options = await authService.getAuthOptions();
      final response = await dio.get(
        '/api/v1/publications/user-publications',
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
        return PaginatedPublicationsModel.fromJson(response.data);
      } catch (e, stackTrace) {
        debugPrint('Error parsing response: $e');
        debugPrint('Stack trace: $stackTrace');
        debugPrint('Response data: ${response.data}');
        throw ServerExeption(message: 'Failed to parse response');
      }
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
  Future<void> updatePublication(UpdatePostModel publication, String id) async {
    try {
      final options = await authService.getAuthOptions();
      final response = await dio.patch(
        '/api/v1/publications/update/$id',
        data: publication.toJson(),
        options: options,
      );

      debugPrint("❤️❤️ ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        throw ServerExeption(
            message: 'Unexpected status code: ${response.statusCode}');
      }
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
  Future<void> deletePublication(String id) async {
    try {
      final options = await authService.getAuthOptions();
      final response = await dio.delete(
        '/api/v1/publications/delete/$id',
        options: options,
      );

      debugPrint("❤️❤️ ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        throw ServerExeption(
            message: 'Unexpected status code: ${response.statusCode}');
      }
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
  Future<PaginatedPublicationsModel> getUserLikedPublications({
    required int page,
    required int size,
  }) async {
    try {
      final options = await authService.getAuthOptions();
      final response = await dio.get(
        '/api/v1/publications/like',
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
        return PaginatedPublicationsModel.fromJson(response.data);
      } catch (e, stackTrace) {
        debugPrint('Error parsing response: $e');
        debugPrint('Stack trace: $stackTrace');
        debugPrint('Response data: ${response.data}');
        throw ServerExeption(message: 'Failed to parse response');
      }
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

}
