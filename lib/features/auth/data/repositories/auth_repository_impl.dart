// ignore_for_file: unused_catch_clause

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/auth/data/models/retrived_email_model.dart';

import 'package:list_in/features/auth/data/sources/auth_local_data_source.dart';
import 'package:list_in/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:list_in/features/auth/domain/entities/auth_tokens.dart';
import 'package:list_in/features/auth/domain/entities/login.dart';
import 'package:list_in/features/auth/domain/entities/retrived_email.dart';
import 'package:list_in/features/auth/domain/entities/signup.dart';
import 'package:list_in/features/auth/domain/entities/user.dart';
import 'package:list_in/features/auth/domain/entities/verify_email.dart';
import 'package:list_in/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, AuthToken>> login(Login login) async {
    try {
      final result = await authRemoteDataSource.login(login);
      return result.fold(
        (error) {
          // Check the error message to determine the correct Failure type
          if (error.contains('Invalid credentials') ||
              error.contains('Invalid email or password')) {
            return Left(ValidationFailure());
          } else if (error.contains('timeout') ||
              error.contains('Network error')) {
            return Left(NetworkFailure());
          } else if (error.contains('Server')) {
            return Left(ServerFailure());
          }
          return Left(UnexpectedFailure());
        },
        (authToken) async {
          await authLocalDataSource.cacheAuthToken(authToken);
          return Right(authToken);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AuthToken>> registerUserData(User user) async {
    try {
      final result = await authRemoteDataSource.registerUserData(user);
      return result.fold(
        (error) {
          // ignore: avoid_print
          print('Remote login error: $error');
          return Left(ServerFailure());
        },
        (authToken) async {
          if (authToken != null) {
            await authLocalDataSource.cacheAuthToken(authToken);
            return Right(authToken);
          } else {
            return Left(ServerFailure());
          }
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Repository login error: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, RetrivedEmail>> signup(Signup signup) async {
    try {
      final result = await authRemoteDataSource.signup(signup);
      return result.fold(
        (error) {
          // ignore: avoid_print
          print('Remote signup error: $error');
          return Left(ServerFailure());
        },
        (retrivedEmail) async {
          if (retrivedEmail != null) {
            await authLocalDataSource.cacheRetrivedEmail(retrivedEmail);
            return Right(retrivedEmail);
          } else {
            // ignore: avoid_print
            print('Email empty retrived!!!!!!!');
            return Left(ServerFailure());
          }
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Repository signup error: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmailSignup(
      VerifyEmail verifyEmail) async {
    try {
      final result = await authRemoteDataSource.verifyEmailSignup(verifyEmail);
      return result.fold(
        (error) => Left(ServerFailure()),
        (_) => const Right(null),
      );
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<AuthToken?> getStoredAuthToken() async {
    return await authLocalDataSource.getLastAuthToken();
  }

  @override
  Future<void> logout() async {
    return await authLocalDataSource.clearAuthToken();
  }

  @override
  Future<void> deleteRetrivedEmail() async {
    return await authLocalDataSource.deleteRetrivedEmail();
  }

  @override
  Future<RetrivedEmail?> getStoredEmail() async {
    return await authLocalDataSource.getRetrivedEmail();
  }

  @override
  Future<Either<Failure, AuthToken>> googleAuth(
      String idToken, String email) async {
    try {
      final result = await authRemoteDataSource.googleAuth(idToken, email);
      return result.fold(
        (error) async {
          debugPrint('Remote Google auth error: $error');

          // Special case: If we get the special 'REGISTRATION_NEEDED' error
          // Store the email so it can be used in registration
          if (error == 'REGISTRATION_NEEDED') {
            // Create and store the email using the existing local data source
            final retrivedEmail = RetrivedEmailModel.fromEmail(email);
            await authLocalDataSource.cacheRetrivedEmail(retrivedEmail);

            // Return our special failure type
            return Left(RegistrationNeededFailure());
          }

          // Regular error handling
          if (error.contains('Not Authenticated') ||
              error.contains('User not authorized')) {
            return Left(ValidationFailure());
          } else if (error.contains('timeout') ||
              error.contains('Network error')) {
            return Left(NetworkFailure());
          } else if (error.contains('Server')) {
            return Left(ServerFailure());
          }
          return Left(UnexpectedFailure());
        },
        (authTokenModel) {
          // Check if tokens are present (this should not be necessary now
          // since we handle empty tokens in the data source, but keeping as a safeguard)
          if (authTokenModel.accessToken.isNotEmpty &&
              authTokenModel.refreshToken.isNotEmpty) {
            // Cache the auth token
            authLocalDataSource.cacheAuthToken(authTokenModel);
            return Right(authTokenModel.toEntity());
          } else {
            // No tokens - indicate need for registration
            return Left(RegistrationNeededFailure());
          }
        },
      );
    } catch (e) {
      debugPrint('Repository Google auth error: $e');
      return Left(UnexpectedFailure());
    }
  }
}
