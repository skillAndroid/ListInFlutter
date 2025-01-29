import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/services/auth_service.dart';
import 'package:list_in/features/explore/data/models/prediction_model.dart';
import 'package:list_in/features/explore/data/models/publication_model.dart';

abstract class PublicationsRemoteDataSource {
  Future<List<PublicationPairModel>> getPublications({
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

  Future<List<PredictionModel>> getPredictions(String? query);
}

class PublicationsRemoteDataSourceImpl implements PublicationsRemoteDataSource {
  final Dio dio;
  final AuthService authService;

  PublicationsRemoteDataSourceImpl({
    required this.dio,
    required this.authService,
  });

  @override
  Future<List<PublicationPairModel>> getPublications({
    String? categoryId,
    String? subcategoryId,
    String? query,
    int? page,
    int? size,
    bool? bargain,
    String? condition,
    double? priceFrom,
    double? priceTo,
    List? filters,
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
        if (filters != null && filters.isNotEmpty) 'filter': filters,
      };

      String url = '/api/v1/publications';

      // Если query не null, используем путь '/search/all/'
      if (query != null && query.isNotEmpty) {
        url += '/search/all';
      } else if (categoryId != null) {
        // Иначе формируем путь в зависимости от categoryId и subcategoryId
        if (subcategoryId != null) {
          url += '/search/all/$categoryId/$subcategoryId';
        } else {
          url += '/p/$categoryId';
        }
      }

      final response = await dio.get(
        url,
        queryParameters: queryParams,
        options: options,
      );

      final paginatedResponse = (response.data as List)
          .map((item) => PublicationPairModel.fromJson(item))
          .toList();

      debugPrint("😇😇Success");
      return paginatedResponse;
    } on DioException catch (e) {
      debugPrint("😇😇Exeption in fetching data remout DIO EXCEPTION $e");
      throw _handleDioException(e);
    } catch (e) {
      debugPrint("😇😇Exeption in fetching data remout $e");
      throw UknownExeption();
    }
  }

  @override
  Future<List<PredictionModel>> getPredictions(String? query) async {
    try {
      final options = await authService.getAuthOptions();
      final queryParams = {
        'query': query ?? '',
      };

      String url = '/api/v1/publications/search/input-predict';
      final response = await dio.get(
        url,
        queryParameters: queryParams,
        options: options,
      );
      final paginatedResponse = (response.data as List)
          .map((item) => PredictionModel.fromJson(item))
          .toList();

      debugPrint("😇😇Success");
      return paginatedResponse;
    } on DioException catch (e) {
      debugPrint("😇😇Exeption in fetching data remout DIO EXCEPTION $e");
      throw _handleDioException(e);
    } catch (e) {
      debugPrint("😇😇Exeption in fetching data remout $e");
      throw UknownExeption();
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
