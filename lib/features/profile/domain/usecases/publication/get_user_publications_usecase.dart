import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/profile/domain/entity/publication/paginated_publications_entity.dart';
import 'package:list_in/features/profile/domain/repository/user_publications_repository.dart';

class GetUserPublicationsUseCase
    extends UseCase2<PaginatedPublicationsEntity, GetUserPublicationsParams> {
  final UserPublicationsRepository repository;

  GetUserPublicationsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedPublicationsEntity>> call(
      {GetUserPublicationsParams? params}) async {
    if (params == null) throw ArgumentError('Params cannot be null');

    return await repository.getUserPublications(
      page: params.page,
      size: params.size,
    );
  }
}

class GetUserPublicationsParams {
  final int page;
  final int size;

  GetUserPublicationsParams({
    required this.page,
    required this.size,
  });
}
