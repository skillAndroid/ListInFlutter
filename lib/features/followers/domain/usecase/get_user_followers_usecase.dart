import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/followers/domain/entity/user_followings_followers_data.dart';
import 'package:list_in/features/followers/domain/repository/user_social_repository.dart';

class UserSocialParams {
  final String userId;
  final int page;
  final int size;

  UserSocialParams({
    required this.userId,
    this.page = 0,
    this.size = 5,
  });
}

class GetUserFollowersUseCase
    extends UseCase2<PaginatedResponse<UserProfile>, UserSocialParams> {
  final UserSocialRepository repository;

  GetUserFollowersUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedResponse<UserProfile>>> call(
      {UserSocialParams? params}) async {
    if (params == null) {
      return Left(ServerFailure());
    }

    try {
      final result = await repository.getFollowers(params.userId,
          page: params.page, size: params.size);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
