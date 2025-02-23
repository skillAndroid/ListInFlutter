
import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/profile/domain/entity/publication/paginated_publications_entity.dart';
import 'package:list_in/features/profile/domain/repository/user_publications_repository.dart';

class GetUserLikedPublicationsUseCase
    extends UseCase2<PaginatedPublicationsEntity, GetUserLikedPublicationsParams> {
  final UserPublicationsRepository repository;

  GetUserLikedPublicationsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedPublicationsEntity>> call(
      {GetUserLikedPublicationsParams? params}) async {
    if (params == null) throw ArgumentError('Params cannot be null');

    return await repository.getUserLikedPublications(
      page: params.page,
      size: params.size,
    );
  }
}

class GetUserLikedPublicationsParams {
  final int page;
  final int size;

  GetUserLikedPublicationsParams({
    required this.page,
    required this.size,
  });
}
