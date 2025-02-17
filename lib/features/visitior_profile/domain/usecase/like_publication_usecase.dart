import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/visitior_profile/domain/repository/another_user_profile_repository.dart';

class LikePublicationUsecase
    extends UseCase2<void, LikeParams> {
  final AnotherUserProfileRepository repository;

  LikePublicationUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(
      {LikeParams? params}) async {
    if (params == null) return Left(ValidationFailure());
    return await repository.likePublication(params.publicationId, params.isLiked);
  }
}

class LikeParams {
  final String publicationId;
  final bool isLiked;

  LikeParams({
    required this.publicationId,
    required this.isLiked,
  });
}