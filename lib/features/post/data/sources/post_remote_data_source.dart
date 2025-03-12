import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/services/auth_service.dart';
import 'package:list_in/features/post/data/models/category_tree/category_model.dart';
import 'package:list_in/features/post/data/models/category_tree/post_model.dart';
import 'package:list_in/features/post/data/models/location_tree/location_model.dart';

abstract class CatalogRemoteDataSource {
  Future<List<CategoryModel>> getCatalogs();
  Future<List<Country>> getLocations();
  Future<List<String>> uploadImages(List<XFile> images);
  Future<String> uploadVideo(XFile video);
  Future<String> createPost(PostModel post);
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final Dio dio;
  final AuthService authService;

  CatalogRemoteDataSourceImpl({
    required this.dio,
    required this.authService,
  });

  @override
  Future<List<CategoryModel>> getCatalogs() async {
    try {
      final options = await authService.getAuthOptions();
      final response = await dio.get(
        '/api/v1/category-tree',
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is List) {
          try {
            final catalogs = (response.data as List)
                .map((json) =>
                    CategoryModel.fromJson(json as Map<String, dynamic>))
                .toList();
            debugPrint("😤😤 Success in remoute fetching data!");
            debugPrint("😤😤 ${catalogs.length}");
            return catalogs;
          } catch (e) {
            debugPrint("😤😤 Parsing data !$e");
            throw ServerExeption(message: 'Error parsing catalog data: $e');
          }
        } else {
          debugPrint("😤😤Invalid response format: expected a list");
          throw ServerExeption(
              message: 'Invalid response format: expected a list');
        }
      } else {
        throw ServerExeption(message: 'Failed to fetch catalogs');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        debugPrint("😤😤DIO ERROR: $e");
        throw ServerExeption(message: 'Connection timeout');
      } else if (e.response?.statusCode == 401) {
        debugPrint("😤😤DIO ERROR: $e");
        throw ServerExeption(message: 'Invalid or expired token');
      }
      debugPrint("😤😤DIO ERROR: $e");
      throw ServerExeption(message: e.message ?? 'Server error');
    } catch (e) {
      debugPrint("😤😤Error try chatch : $e");
      throw ServerExeption(message: e.toString());
    }
  }

  @override
  Future<List<String>> uploadImages(List<XFile> images) async {
    final options = await authService.getAuthOptions();

    try {
      // Формируем FormData
      final formData = FormData();
      for (var i = 0; i < images.length; i++) {
        final file = await MultipartFile.fromFile(
          images[i].path,
          filename: images[i].name,
        );
        formData.files.add(MapEntry('images', file));
      }

      // Логируем содержимое FormData
      debugPrint('formData');

      // Отправляем запрос
      final response = await dio.post(
        '/api/v1/files/upload/images',
        data: formData,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Here is the responce of the data : ${response.data}");
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
  Future<String> uploadVideo(XFile video) async {
    try {
      final options = await authService.getAuthOptions();
      final file = await MultipartFile.fromFile(
        video.path,
        filename: 'video.mp4',
      );
      final formData = FormData();
      formData.files.add(MapEntry('video', file));
      final response = await dio.post(
        '/api/v1/files/upload/video',
        data: formData,
        options: options,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Here is the responce of the data : ${response.data}");
        return response.data;
      } else {
        throw ServerExeption(message: 'Failed to upload video');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          throw ConnectiontTimeOutExeption();
        }
        throw ServerExeption(message: e.message ?? 'Unknown error occurred');
      }
      throw ServerExeption(message: 'Failed to upload video');
    }
  }

  @override
  Future<String> createPost(PostModel post) async {
    try {
      final options = await authService.getAuthOptions();

      final response = await dio.post(
        '/api/v1/publications',
        data: post.toJson(),
        options: options,
      );

      if (response.statusCode == 201) {
        return response.data;
      }
      throw ServerExeption(message: 'Failed to create post');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Country>> getLocations() async {
    try {
      final options = await authService.getAuthOptions();
      final response = await dio.get(
        '/api/v1/location-tree',
        options: options,
      );

      debugPrint("🔍 Response status code: ${response.statusCode}");
      debugPrint("🔍 Response type: ${response.data.runtimeType}");
      debugPrint(
          "🔍 Response preview: ${response.data.toString().substring(0, min(200, response.data.toString().length))}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is List) {
          try {
            final locations = (response.data as List)
                .map((json) => Country.fromJson(json as Map<String, dynamic>))
                .toList();
            debugPrint("😤😤 Success in remote fetching data locations!");
            debugPrint("😤😤 ${locations.length}");
            return locations;
          } catch (e) {
            debugPrint("😤😤 Parsing data error! $e");
            debugPrint(
                "😤😤 First item preview: ${response.data.isNotEmpty ? response.data[0].toString() : 'Empty list'}");
            throw ServerExeption(message: 'Error parsing location data: $e');
          }
        } else if (response.data is Map<String, dynamic>) {
          // Try to handle if it's an object with a data/items field
          final map = response.data as Map<String, dynamic>;
          debugPrint(
              "🔍 Received Map instead of List. Keys: ${map.keys.join(', ')}");

          // Check for common container fields
          if (map.containsKey('data') && map['data'] is List) {
            try {
              final locations = (map['data'] as List)
                  .map((json) => Country.fromJson(json as Map<String, dynamic>))
                  .toList();
              debugPrint("😤😤 Successfully parsed data field as list");
              return locations;
            } catch (e) {
              debugPrint("😤😤 Error parsing 'data' field: $e");
              throw ServerExeption(message: 'Error parsing data field: $e');
            }
          } else if (map.containsKey('items') && map['items'] is List) {
            try {
              final locations = (map['items'] as List)
                  .map((json) => Country.fromJson(json as Map<String, dynamic>))
                  .toList();
              debugPrint("😤😤 Successfully parsed items field as list");
              return locations;
            } catch (e) {
              debugPrint("😤😤 Error parsing 'items' field: $e");
              throw ServerExeption(message: 'Error parsing items field: $e');
            }
          } else if (map.containsKey('locations') && map['locations'] is List) {
            try {
              final locations = (map['locations'] as List)
                  .map((json) => Country.fromJson(json as Map<String, dynamic>))
                  .toList();
              debugPrint("😤😤 Successfully parsed locations field as list");
              return locations;
            } catch (e) {
              debugPrint("😤😤 Error parsing 'locations' field: $e");
              throw ServerExeption(
                  message: 'Error parsing locations field: $e');
            }
          } else if (map.containsKey('countries') && map['countries'] is List) {
            // Add check for 'countries' field based on Swagger example
            try {
              final locations = (map['countries'] as List)
                  .map((json) => Country.fromJson(json as Map<String, dynamic>))
                  .toList();
              debugPrint("😤😤 Successfully parsed countries field as list");
              return locations;
            } catch (e) {
              debugPrint("😤😤 Error parsing 'countries' field: $e");
              throw ServerExeption(
                  message: 'Error parsing countries field: $e');
            }
          } else {
            // This might be a single country
            try {
              final country = Country.fromJson(map);
              debugPrint("😤😤 Parsed a single country object");
              return [country];
            } catch (e) {
              debugPrint("😤😤 Not a valid single country object: $e");
              throw ServerExeption(
                  message:
                      'Invalid response format: expected a list but got a map that couldn\'t be parsed');
            }
          }
        } else {
          debugPrint(
              "😤😤 Invalid response format: expected a list but got ${response.data.runtimeType}");
          throw ServerExeption(
              message:
                  'Invalid response format: expected a list but got ${response.data.runtimeType}');
        }
      } else {
        throw ServerExeption(
            message:
                'Failed to fetch locations: Status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        debugPrint("😤😤 DIO ERROR: $e");
        throw ServerExeption(message: 'Connection timeout');
      } else if (e.response?.statusCode == 401) {
        debugPrint("😤😤 DIO ERROR: $e");
        throw ServerExeption(message: 'Invalid or expired token');
      }
      debugPrint("😤😤 DIO ERROR: $e");
      debugPrint("😤😤 Response data: ${e.response?.data}");
      throw ServerExeption(message: e.message ?? 'Server error');
    } catch (e) {
      debugPrint("😤😤 Error try catch: $e");
      throw ServerExeption(message: e.toString());
    }
  }

// Helper function
  int min(int a, int b) => (a < b) ? a : b;
}
