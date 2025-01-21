import 'package:dio/dio.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/services/auth_service.dart';
import 'package:list_in/features/explore/data/models/publication_model.dart';

abstract class PublicationsRemoteDataSource {
  Future<List<GetPublicationModel>> getPublications({
    String? query,
    int? page,
    int? size,
    bool? bargain,
    String? condition,
    double? priceFrom,
    double? priceTo,
  });

  Future<List<GetPublicationModel>> getPublicationsFiltered({
    String? categoryId,
    String? subcategoryId,
    String? query,
    int? page,
    int? size,
    bool? bargain,
    String? condition,
    double? priceFrom,
    double? priceTo,
    List<String>? filters,
  });
}

class PublicationsRemoteDataSourceImpl implements PublicationsRemoteDataSource {
  final Dio dio;
  final AuthService authService;

  PublicationsRemoteDataSourceImpl({
    required this.dio,
    required this.authService,
  });

  @override
  Future<List<GetPublicationModel>> getPublications({
    String? query,
    int? page,
    int? size,
    bool? bargain,
    String? condition,
    double? priceFrom,
    double? priceTo,
  }) async {
    try {
      final options = await authService.getAuthOptions();

      final queryParams = {
        'query': query ?? '',
        if (page != null) 'page': page.toString(),
        if (size != null) 'size': size.toString(),
        if (bargain != null) 'bargain': bargain.toString(),
        if (condition != null) 'condition': condition,
        if (priceFrom != null) 'from': priceFrom.toString(),
        if (priceTo != null) 'to': priceTo.toString(),
      };

      final response = await dio.get(
        '/api/v1/publications/search/all',
        queryParameters: queryParams,
        options: options,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = response.data;
        final List<dynamic> content = jsonResponse['content'];
        return content
            .map((item) => GetPublicationModel.fromJson(item))
            .toList();
      } else if (response.statusCode == 404) {
        throw NotFoundExeption();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access');
      } else if (response.statusCode! >= 500) {
        throw ServerExeption(message: 'Server error occurred');
      } else {
        throw BadResponse(
            message: 'Unexpected response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw ConnectiontTimeOutExeption();
      } else if (e.type == DioExceptionType.connectionError) {
        throw ConnectionExeption(message: 'No internet connection');
      } else {
        throw ServerExeption(message: e.message ?? 'Server error occurred');
      }
    } catch (e) {
      throw UknownExeption();
    }
  }

  @override
  Future<List<GetPublicationModel>> getPublicationsFiltered({
    String? categoryId,
    String? subcategoryId,
    String? query,
    int? page,
    int? size,
    bool? bargain,
    String? condition,
    double? priceFrom,
    double? priceTo,
    List<String>? filters,
  }) async {
    try {
      final options = await authService.getAuthOptions();

      final queryParams = <String, dynamic>{
        'query': query ?? '',
        if (page != null) 'page': page.toString(),
        if (size != null) 'size': size.toString(),
        if (bargain != null) 'bargain': bargain.toString(),
        if (condition != null) 'condition': condition,
        if (priceFrom != null) 'from': priceFrom.toString(),
        if (priceTo != null) 'to': priceTo.toString(),
        if (filters != null && filters.isNotEmpty) 'filter': filters,
      };

      String url = '/api/v1/publications/search/all';
      if (categoryId != null) {
        url += '/$categoryId';
        if (subcategoryId != null) {
          url += '/$subcategoryId';
        }
      }

      final response = await dio.get(
        url,
        queryParameters: queryParams,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw UknownExeption();
    }
  }

  List<GetPublicationModel> _handleResponse(Response response) {
    switch (response.statusCode) {
      case 200:
        final jsonResponse = response.data as Map<String, dynamic>;
        final content = jsonResponse['content'] as List<dynamic>;
        return content
            .map((item) => GetPublicationModel.fromJson(item))
            .toList();
      case 404:
        throw NotFoundExeption();
      case 401:
        throw UnauthorizedException('Unauthorized access');
      case 500:
        throw ServerExeption(message: 'Server error occurred');
      default:
        throw BadRequestExeption(
          message: 'Unexpected response: ${response.statusCode}',
        );
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ConnectiontTimeOutExeption();
      case DioExceptionType.connectionError:
        return ConnectionExeption(
          message: 'No internet connection',
        );
      default:
        return ServerExeption(
          message: e.message ?? 'Server error occurred',
        );
    }
  }
}
