import 'package:dio/dio.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/services/auth_service.dart';
import 'package:list_in/features/post/data/models/category.dart';

abstract class CatalogRemoteDataSource {
  Future<List<Category>> getCatalogs();
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final Dio dio;
  final AuthService authService;

  CatalogRemoteDataSourceImpl({
    required this.dio,
    required this.authService,
  });

  @override
  Future<List<Category>> getCatalogs() async {
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
                .map((json) => Category.fromJson(json as Map<String, dynamic>))
                .toList();

            return catalogs;
          } catch (e) {
            throw ServerExeption(
                message: 'Error parsing catalog data: ${e.toString()}');
          }
        } else {
          throw ServerExeption(
              message: 'Invalid response format: expected a list of catalogs');
        }
      } else {
        throw ServerExeption(message: 'Failed to fetch catalogs');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ConnectionExeption(message: 'Connection timeout');
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      }
      throw ServerExeption(message: e.message ?? 'Server error');
    } catch (e) {
      throw ServerExeption(message: e.toString());
    }
  }
}
