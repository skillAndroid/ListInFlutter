// ignore_for_file: avoid_print

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:list_in/core/dto/user_data_dto.dart';
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
  Future<Either<Failure, UserDataDtoEntity>> login(Login login) async {
    try {
      print("🚀 Starting login process for: ${login.email}");

      final result = await authRemoteDataSource.login(login);

      return result.fold(
        (error) {
          print("❌ Error in login: $error"); // Debug error messages

          // Check the error message to determine the correct Failure type
          if (error.contains('Invalid credentials') ||
              error.contains('Invalid email or password')) {
            print("🔴 Validation Failure");
            return Left(ValidationFailure());
          } else if (error.contains('timeout') ||
              error.contains('Network error')) {
            print("🔴 Network Failure");
            return Left(NetworkFailure());
          } else if (error.contains('Server')) {
            print("🔴 Server Failure");
            return Left(ServerFailure());
          }
          print("🔴 Unexpected Failure");
          return Left(UnexpectedFailure());
        },
        (userData) async {
          print("✅ Login successful - reaching userData");
          print("😂 User ID: ${userData.user.id}");
          print("😂 Profile Image Path: ${userData.user.profileImagePath}");

          try {
            await authLocalDataSource.cacheAuthToken(userData.tokens);
            print("✅ Token cached");

            await authLocalDataSource.cacheUserId(userData.user.id);
            print("✅ User ID cached");

            await authLocalDataSource
                .cacheProfileImagePath(userData.user.profileImagePath);
            print("✅ Profile image path cached");

            final entity = userData.toEntity();
            print("✅ Converted to entity");
            return Right(entity);
          } catch (cacheError) {
            print("❌ Error caching data: $cacheError");
            return Left(UnexpectedFailure());
          }
        },
      );
    } catch (e) {
      print("❌ Unexpected error in login: $e");
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, UserDataDtoEntity>> registerUserData(User user) async {
    try {
      final result = await authRemoteDataSource.registerUserData(user);
      return result.fold(
        (error) {
          print('Remote login error: $error');
          return Left(ServerFailure());
        },
        (userData) async {
          print("✅ Login successful - reaching userData");
          print("😂 User ID: ${userData.user.id}");
          print("😂 Profile Image Path: ${userData.user.profileImagePath}");
          await authLocalDataSource.cacheAuthToken(userData.tokens);
          await authLocalDataSource.cacheUserId(userData.user.id);
          await authLocalDataSource
              .cacheProfileImagePath(userData.user.profileImagePath);
          return Right(userData.toEntity());
        },
      );
    } catch (e) {
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
          print('Remote signup error: $error');
          return Left(ServerFailure());
        },
        (retrivedEmail) async {
          if (retrivedEmail != null) {
            await authLocalDataSource.cacheRetrivedEmail(retrivedEmail);
            return Right(retrivedEmail);
          } else {
            print('Email empty retrived!!!!!!!');
            return Left(ServerFailure());
          }
        },
      );
    } catch (e) {
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
  Future<Either<Failure, UserDataDtoEntity>> googleAuth(
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
        (userData) async {
          print("✅ Login successful - reaching userData");
          print("😂 User ID: ${userData.user.id}");
          print("😂 Profile Image Path: ${userData.user.profileImagePath}");
          await authLocalDataSource.cacheAuthToken(userData.tokens);
          await authLocalDataSource.cacheUserId(userData.user.id);
          await authLocalDataSource
              .cacheProfileImagePath(userData.user.profileImagePath);
          return Right(userData.toEntity());
        },
      );
    } catch (e) {
      debugPrint('Repository Google auth error: $e');
      return Left(UnexpectedFailure());
    }
  }
}
