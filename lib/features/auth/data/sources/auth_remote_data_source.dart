// ignore_for_file: avoid_print

import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:list_in/core/dto/user_data_dto.dart';
import 'package:list_in/features/auth/data/models/retrived_email_model.dart';
import 'package:list_in/features/auth/domain/entities/login.dart';
import 'package:list_in/features/auth/domain/entities/signup.dart';
import 'package:list_in/features/auth/domain/entities/user.dart';
import 'package:list_in/features/auth/domain/entities/verify_email.dart';

abstract class AuthRemoteDataSource {
  Future<Either<String, UserDataDtoModel>> login(Login login);
  Future<Either> signup(Signup signup);
  Future<Either> verifyEmailSignup(VerifyEmail verifyEmail);
  Future<Either<String, UserDataDtoModel>> registerUserData(User user);
  Future<Either<String, UserDataDtoModel>> googleAuth(
      String idToken, String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<Either<String, UserDataDtoModel>> login(Login login) async {
    try {
      final startTime = DateTime.now();
      print("⏳ Отправка запроса: $startTime");
      final response = await dio.post('/api/v1/auth/authenticate', data: {
        'email': login.email,
        'password': login.password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final endTime = DateTime.now();
        print(
            "✅ Ответ получен: $endTime, задержка: ${endTime.difference(startTime).inMilliseconds} мс");
        return right(UserDataDtoModel.fromJson(response.data));
      } else {
        // Handle non-200/201 responses
        return left(response.data['message'] ??
            'Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle 401 and other auth errors specifically
      if (e.response?.statusCode == 401) {
        return left('Invalid email or password');
      }

      if (e.response?.statusCode == 401) {
        return left('Not Authenticated');
      }

      // Handle other DioError cases
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return left('Connection timeout');
        case DioExceptionType.badResponse:
          // Get the error message from the response if available
          final message = e.response?.data['message'];
          if (message != null && message.toString().contains('credentials')) {
            return left('Invalid credentials');
          }
          return left(
              e.response?.data['message'] ?? 'Bad response from server');
        default:
          return left(e.message ?? 'Network error occurred');
      }
    } catch (e) {
      return left('Unexpected error occurred');
    }
  }

  @override
  Future<Either<String, UserDataDtoModel>> registerUserData(User user) async {
    try {
      final responce = await dio.post(
        '/api/v1/auth/register',
        options: Options(
          headers: {
            'Accept-Language': 'ru',
          },
        ),
        data: {
          'nickName': user.nikeName,
          'phoneNumber': user.phoneNumber,
          'email': user.email,
          'password': user.password,
          'roles': user.roles,
          'locationName': user.locationName,
          'city': user.city,
          'county': user.county,
          'country': user.country,
          'state': user.state,
          'isGrantedForPreciseLocation': user.isGrantedForPreciseLocation,
          'latitude': user.latitude,
          'longitude': user.longitude
        },
      );

      if (responce.statusCode == 200 || responce.statusCode == 201) {
        return right(UserDataDtoModel.fromJson(responce.data));
      } else {
        return left('Server returned ${responce.statusCode}');
      }
    } on DioException catch (e) {
      return left(e.message ?? 'Network error occured');
    } catch (e) {
      return left('Unexpected error occured');
    }
  }

  @override
  Future<Either<String, UserDataDtoModel>> googleAuth(
      String idToken, String email) async {
    try {
      print('🚀 Sending Google Auth Request:');
      print('Email: $email');
      print('ID Token Length: ${idToken.length}');
      print(
          'ID Token (first 10 chars): ${idToken.substring(0, min(10, idToken.length))}...');

      // Validate input before sending
      if (idToken.isEmpty || email.isEmpty) {
        print('❌ Invalid input: Empty idToken or email');
        return left('Invalid authentication parameters');
      }

      final response = await dio.post(
        '/api/v1/oauth/google/mobile',
        queryParameters: {
          'idToken': idToken,
          'email': email,
        },
      );

      // Detailed response logging
      print('📬 Response Details:');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        // Check if tokens are present
        if (responseData['access_token'] == null ||
            responseData['refresh_token'] == null ||
            responseData['access_token'] == '' ||
            responseData['refresh_token'] == '') {
          print('⚠️ Auth successful but no tokens - user needs registration');
          // Return a special value to indicate registration needed
          return left('REGISTRATION_NEEDED');
        }

        return right(UserDataDtoModel.fromJson(responseData));
      } else {
        print('❌ Unexpected Status Code: ${response.statusCode}');
        print('Error Response: ${response.data}');
        return left('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Comprehensive Dio error logging
      print('🚨 Dio Error Details:');
      print('Error Type: ${e.type}');
      print('Error Response: ${e.response?.data}');
      print('Error Message: ${e.message}');
      print('Status Code: ${e.response?.statusCode}');

      // Specific error handling
      if (e.response?.statusCode == 302) {
        print('🔄 Redirection Detected');
        print('Redirect Headers: ${e.response?.headers}');
      }

      return left(e.message ?? 'Network error occurred');
    } catch (e) {
      print('🚨 Unexpected Error: $e');
      return left('Unexpected error during authentication');
    }
  }

  @override
  Future<Either<String, RetrivedEmailModel>> signup(Signup signup) async {
    try {
      final response = await dio.post('/api/v1/auth/send/mail', data: {
        'email': signup.email,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return right(RetrivedEmailModel.fromJson(response.data));
      } else {
        return left('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      return left(e.message ?? 'Network error occurred');
    } catch (e) {
      return left('Unexpected error occurred initial');
    }
  }

  //
  @override
  Future<Either<String, dynamic>> verifyEmailSignup(
      VerifyEmail verifyEmail) async {
    try {
      final responce = await dio.post(
        '/api/v1/auth/verify/email',
        queryParameters: {
          'code': verifyEmail.code,
        },
        data: {
          'email': verifyEmail.email,
        },
      );

      if (responce.statusCode == 200 || responce.statusCode == 201) {
        return right(responce.data);
      } else {
        return left('Server returned ${responce.statusCode}');
      }
    } catch (e) {
      return left('Unexpected error occurred');
    }
  }
}
