import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/auth/data/models/auth_token_model.dart';
import 'package:list_in/features/auth/data/sources/auth_local_data_source.dart';
import 'package:list_in/features/auth/domain/entities/auth_tokens.dart';
import 'package:list_in/features/profile/domain/entity/user/user_data_entity.dart';
import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';
import 'package:list_in/features/profile/domain/repository/user_profile_repository.dart';

class UpdateUserProfileUseCase
    extends UseCase2<(UserDataEntity, AuthToken?), UserProfileEntity> {
  final UserProfileRepository repository;
  final AuthLocalDataSource authLocalDataSource;

  UpdateUserProfileUseCase({
    required this.repository,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, (UserDataEntity, AuthToken?)>> call(
      {UserProfileEntity? params}) async {
    if (params == null) return Left(ValidationFailure());

    try {
      final result = await repository.updateUserData(params);

      // Handle token caching
      await result.fold(
        (failure) => Future.value(),
        (userDataAndToken) async {
          final (_, tokens) = userDataAndToken;
          if (tokens != null) {
            await authLocalDataSource.cacheAuthToken(
              AuthTokenModel(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken,
              ),
            );
          }
        },
      );

      return result;
    } on CacheExeption {
      return Left(CacheFailure());
    }
  }
}
