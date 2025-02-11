import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/visitior_profile/domain/entity/another_user_profile_entity.dart';
import 'package:list_in/features/visitior_profile/domain/repository/another_user_profile_repository.dart';

class FollowUserUseCase
    extends UseCase2<AnotherUserProfileEntity, FollowParams> {
  final AnotherUserProfileRepository repository;

  FollowUserUseCase(this.repository);

  @override
  Future<Either<Failure, AnotherUserProfileEntity>> call(
      {FollowParams? params}) async {
    if (params == null) return Left(ValidationFailure());
    return await repository.followUser(params.userId, params.isFollowing);
  }
}

class FollowParams {
  final String userId;
  final bool isFollowing;

  FollowParams({
    required this.userId,
    required this.isFollowing,
  });
}
