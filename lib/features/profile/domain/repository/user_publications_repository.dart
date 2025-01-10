import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/profile/domain/entity/publication/paginated_publications_entity.dart';

abstract class UserPublicationsRepository {
  Future<Either<Failure, PaginatedPublicationsEntity>> getUserPublications({
    required int page,
    required int size,
  });
}