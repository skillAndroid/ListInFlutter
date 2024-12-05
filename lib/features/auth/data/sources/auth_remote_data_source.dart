import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:list_in/features/auth/data/models/auth_token_model.dart';
import 'package:list_in/features/auth/data/models/retrived_email_model.dart';
import 'package:list_in/features/auth/domain/entities/login.dart';
import 'package:list_in/features/auth/domain/entities/signup.dart';
import 'package:list_in/features/auth/domain/entities/user.dart';
import 'package:list_in/features/auth/domain/entities/verify_email.dart';

abstract class AuthRemoteDataSource {
  Future<Either> login(Login login);
  Future<Either> signup(Signup signup);
  Future<Either> verifyEmailSignup(VerifyEmail verifyEmail);
  Future<Either> registerUserData(User user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<Either<String, AuthTokenModel>> login(Login login) async {
    try {
      final response = await dio.post('/api/v1/auth/authenticate', data: {
        'email': login.email,
        'password': login.password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return right(AuthTokenModel.fromJson(response.data));
      } else {
        return left('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      return left(e.message ?? 'Network error occurred');
    } catch (e) {
      return left('Unexpected error occurred');
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

  @override
  Future<Either<String, AuthTokenModel>> registerUserData(User user) async {
    try {
      final responce = await dio.post('/api/v1/auth/register', data: {
        'firstname': user.firstname,
        'lastname': user.lastname,
        'age': user.age,
        'phoneNumber': user.phoneNumber,
        'email': user.email,
        'password': user.password,
        'roles': user.roles
      });

      if (responce.statusCode == 200 || responce.statusCode == 201) {
        return right(AuthTokenModel.fromJson(responce.data));
      } else {
        return left('Server returned ${responce.statusCode}');
      }
    } on DioException catch (e) {
      return left(e.message ?? 'Network error occured');
    } catch (e) {
      return left('Unexpected error occured');
    }
  }
}
