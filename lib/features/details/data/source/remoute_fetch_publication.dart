// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/services/auth_service.dart';
import 'package:list_in/features/explore/data/models/publication_model.dart';

abstract class RemouteFetchPublication {
  Future<GetPublicationModel> getPublication(String id);
}

class RemouteFetchPublicationImpl implements RemouteFetchPublication {
  final Dio dio;
  final AuthService authService;

  RemouteFetchPublicationImpl({
    required this.dio,
    required this.authService,
  });

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
  Future<GetPublicationModel> getPublication(String id) async {
    try {
      final options = await authService.getAuthOptions();
      print('authService $id');
      String url = '/api/v1/publications/$id';

      final response = await dio.get(
        url,
        options: options,
      );

      return GetPublicationModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("😇😇Exception in fetching data remote DIO EXCEPTION $e");
      throw _handleDioException(e);
    } catch (e) {
      debugPrint("😇😇Exception in fetching data remote $e");
      throw UknownExeption();
    }
  }
}
