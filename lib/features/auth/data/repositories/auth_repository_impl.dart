// ignore_for_file: unused_catch_clause

import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/network/network_info.dart';
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
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.authLocalDataSource,
    required this.networkInfo,
  });

  @override
Future<Either<Failure, AuthToken>> login(Login login) async {
  if (await networkInfo.isConnected) {
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
  } else {
    return Left(NetworkFailure());
  }
}

  @override
  Future<Either<Failure, AuthToken>> registerUserData(User user) async {
    if (await networkInfo.isConnected) {
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
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, RetrivedEmail>> signup(Signup signup) async {
    if (await networkInfo.isConnected) {
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
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmailSignup(
      VerifyEmail verifyEmail) async {
    if (await networkInfo.isConnected) {
      try {
        final result =
            await authRemoteDataSource.verifyEmailSignup(verifyEmail);
        return result.fold(
          (error) => Left(ServerFailure()),
          (_) => const Right(null),
        );
      } catch (_) {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
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
}
