import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/services/auth_service.dart';
import 'package:list_in/features/explore/data/models/filter_publications_values_model.dart';
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
    List<String>? numeric,
  });

  Future<List<PredictionModel>> getPredictions(String? query);

  Future<VideoPublicationsModel> getVideoPublications({
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

  Future<FilterPredictionValuesModel> getFilteredValuesOfPublications({
    String? categoryId,
    String? subcategoryId,
    String? query,
    bool? bargain,
    bool? isFree,
    String? sellerType,
    String? condition,
    double? priceFrom,
    double? priceTo,
    List<String>? filters,
    List<String>? numeric,
    CancelToken? cancelToken,
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
    List<String>? numeric,
  }) async {
    try {
      final options = await authService.getAuthOptions();
      final queryParams = {
        if (query != null && query.isNotEmpty) 'query': query,
        if (page != null) 'page': page.toString(),
        if (size != null) 'size': size.toString(),
        if (bargain != null) 'bargain': bargain.toString(),
        if (condition != null) 'condition': condition,
        if (priceFrom != null) 'from': priceFrom.toString(),
        if (priceTo != null) 'to': priceTo.toString(),
        if (filters != null && filters.isNotEmpty) 'filter': filters,
        if (numeric != null && numeric.isNotEmpty) 'numeric': numeric.join(','),
      };

      String url = '/api/v1/publications/search';

      if (categoryId != null) {
        if (subcategoryId != null) {
          url = '$url/$categoryId/$subcategoryId';
        } else {
          url = '$url/$categoryId';
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
      debugPrint("😇😇Exception in fetching data remote DIO EXCEPTION $e");
      throw _handleDioException(e);
    } catch (e) {
      debugPrint("😇😇Exception in fetching data remote $e");
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
      case DioExceptionType.cancel:
        return CancelledException(
          message: 'Request was cancelled',
        );
      default:
        return ServerExeption(
          message: e.message ?? 'Server error occurred',
        );
    }
  }

  @override
  Future<VideoPublicationsModel> getVideoPublications({
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

      String url = '/api/v1/publications/videos';

      if (query != null && query.isNotEmpty && query != "") {
        url += '/search/all';
      } else {
        if (categoryId != null) {
          if (subcategoryId != null) {
            url += '/search/all/$categoryId/$subcategoryId';
          } else {
            url += '/p/$categoryId';
          }
        }
      }

      final response = await dio.get(
        url,
        queryParameters: queryParams,
        options: options,
      );

      return VideoPublicationsModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("😇😇Exception in fetching data remote DIO EXCEPTION $e");
      throw _handleDioException(e);
    } catch (e) {
      debugPrint("😇😇Exception in fetching data remote $e");
      throw UknownExeption();
    }
  }

  @override
  Future<FilterPredictionValuesModel> getFilteredValuesOfPublications({
    String? categoryId,
    String? subcategoryId,
    String? query,
    bool? bargain,
    bool? isFree,
    String? sellerType,
    String? condition,
    double? priceFrom,
    double? priceTo,
    List<String>? filters,
    List<String>? numeric,
    CancelToken? cancelToken,
  }) async {
    try {
      final options = await authService.getAuthOptions();
      final queryParams = {
        if (isFree != null) 'isFree': isFree.toString(),
        if (bargain != null) 'bargain': bargain.toString(),
        if (condition != null) 'condition': condition,
        if (sellerType != null) 'sellerType': sellerType,
        if (priceFrom != null) 'from': priceFrom.toString(),
        if (priceTo != null) 'to': priceTo.toString(),
        if (filters != null && filters.isNotEmpty) 'filter': filters,
        if (numeric != null && numeric.isNotEmpty) 'numeric': numeric.join(','),
      };

      String url = '/api/v1/publications/search/count';

      if (categoryId != null) {
        if (subcategoryId != null) {
          url = '$url/$categoryId/$subcategoryId';
        } else {
          url = '$url/$categoryId';
        }
      }
      final response = await dio.get(
        url,
        queryParameters: queryParams,
        options: options,
        cancelToken: cancelToken,
      );
      final paginatedResponse =
          FilterPredictionValuesModel.fromJson(response.data);

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
}
