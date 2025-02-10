import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/profile/domain/entity/another_user/another_user_profile_entity.dart';
import 'package:list_in/features/profile/domain/repository/another_user_profile_repository.dart';

class GetAnotherUserDataUseCase extends UseCase2<AnotherUserProfileEntity, String?> {
  final AnotherUserProfileRepository repository;

  GetAnotherUserDataUseCase(this.repository);

  @override
  Future<Either<Failure, AnotherUserProfileEntity>> call({String? params}) async {
    debugPrint('🎯 GetAnotherUserDataUseCase called');
    final result = await repository.getUserData(params);
    debugPrint('🎯 GetAnotherUserDataUseCase result: $result');
    return result;
  }
}
