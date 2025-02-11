import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/visitior_profile/domain/entity/another_user_publications_entity.dart';
import 'package:list_in/features/visitior_profile/domain/repository/another_user_profile_repository.dart';

class GetPublicationsByIdParams {
  final String userId;
  final int page;
  final int size;

  GetPublicationsByIdParams({
    required this.userId,
    this.page = 0,
    this.size = 20,
  });
}

class GetPublicationsByIdUsecase
    extends UseCase2<AnotherUserPublicationsEntity, GetPublicationsByIdParams> {
  final AnotherUserProfileRepository repository;

  GetPublicationsByIdUsecase(this.repository);

  @override
  Future<Either<Failure, AnotherUserPublicationsEntity>> call({
    GetPublicationsByIdParams?
        params,
  }) {
    if (params == null) {
      throw ArgumentError('Publications params cannot be null');
    }

    return repository.getUserPublications(
      page: params.page,
      size: params.size,
      userId: params.userId,
    );
  }
}
