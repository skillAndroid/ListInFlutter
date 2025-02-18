import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/auth/data/sources/auth_local_data_source.dart';
import 'package:list_in/features/profile/domain/entity/user/user_data_entity.dart';
import 'package:list_in/features/profile/domain/repository/user_profile_repository.dart';

class GetUserDataUseCase extends UseCase2<UserDataEntity, NoParams> {
  final UserProfileRepository repository;
  final AuthLocalDataSource authLocalDataSource;

  GetUserDataUseCase(this.repository, this.authLocalDataSource);

  @override
  Future<Either<Failure, UserDataEntity>> call({NoParams? params}) async {
    debugPrint('🎯 GetUserDataUseCase called');
    final result = await repository.getUserData();

    String? userId;
    result.fold(
      (failure) => null,
      (userData) async {
        userId = userData.id;
        await authLocalDataSource.cacheUserId(userId!);

        // Here's the key part - immediately update a global static variable
        AppSession.currentUserId = userId;
        debugPrint('🎯 User ID set in AppSession: $userId');
      },
    );

    debugPrint('🎯 GetUserDataUseCase result: $result');
    return result;
  }
}

class AppSession {
  static String? currentUserId;

  // You can add more session-related variables here

  static bool get isLoggedIn => currentUserId != null;
}
