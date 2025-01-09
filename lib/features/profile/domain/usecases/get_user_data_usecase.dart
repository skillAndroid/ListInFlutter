import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/profile/domain/entity/user_data_entity.dart';
import 'package:list_in/features/profile/domain/repository/user_profile_repository.dart';

class GetUserDataUseCase extends UseCase2<UserDataEntity, NoParams> {
  final UserProfileRepository repository;

  GetUserDataUseCase(this.repository);

  @override
  Future<Either<Failure, UserDataEntity>> call({NoParams? params}) async {
    debugPrint('🎯 GetUserDataUseCase called');
    final result = await repository.getUserData();
    debugPrint('🎯 GetUserDataUseCase result: $result');
    return result;
  }
}
