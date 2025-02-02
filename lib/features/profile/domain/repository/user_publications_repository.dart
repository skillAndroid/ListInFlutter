import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/profile/domain/entity/publication/paginated_publications_entity.dart';
import 'package:list_in/features/profile/domain/entity/publication/update_post_entity.dart';

abstract class UserPublicationsRepository {
  Future<Either<Failure, PaginatedPublicationsEntity>> getUserPublications({
    required int page,
    required int size,
  });

  Future<Either<Failure, void>> updatePost(UpdatePostEntity post, String id);
}
