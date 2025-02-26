// Use Case for getting user followings
import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/followers/domain/entity/user_followings_followers_data.dart';
import 'package:list_in/features/followers/domain/repository/user_social_repository.dart';
import 'package:list_in/features/followers/domain/usecase/get_user_followers_usecase.dart';

class GetUserFollowingsUseCase
    extends UseCase2<PaginatedResponse<UserProfile>, UserSocialParams> {
  final UserSocialRepository repository;

  GetUserFollowingsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedResponse<UserProfile>>> call(
      {UserSocialParams? params}) async {
    if (params == null) {
      return Left(ServerFailure());
    }

    try {
      final result = await repository.getFollowings(params.userId,
          page: params.page, size: params.size);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
