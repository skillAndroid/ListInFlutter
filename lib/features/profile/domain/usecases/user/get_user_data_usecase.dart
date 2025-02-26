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
    result.fold(
      (failure) => null,
      (userData) async {
        String userId = userData.id;
        await authLocalDataSource.cacheUserId(userId);
        AppSession.currentUserId = userId;
        if (userData.profileImagePath != null &&
            userData.profileImagePath!.isNotEmpty) {
          await authLocalDataSource
              .cacheProfileImagePath(userData.profileImagePath!);
          AppSession.profileImagePath = userData.profileImagePath;
          AppSession.profileImageUrl = "https://${userData.profileImagePath}";
        } else {         
          await authLocalDataSource.cacheProfileImagePath('');
          AppSession.profileImagePath = null;
          AppSession.profileImageUrl = null;
        }
        debugPrint('🎯 User ID set in AppSession: $userId');
        debugPrint(
            '🎯 Profile image set in AppSession: ${AppSession.profileImageUrl}');
      },
    );
    debugPrint('🎯 GetUserDataUseCase result: $result');
    return result;
  }
}

class AppSession {
  static String? currentUserId;
  static String? profileImagePath;
  static String? profileImageUrl;
  static bool get isLoggedIn => currentUserId != null;
}
