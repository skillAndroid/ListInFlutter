import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/profile/domain/entity/publication/update_post_entity.dart';
import 'package:list_in/features/profile/domain/repository/user_publications_repository.dart';

class UpdatePostUseCase extends UseCase2<void, UpdatePostParams> {
  final UserPublicationsRepository repository;

  UpdatePostUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call({UpdatePostParams? params}) async {
    if (params == null) {
      return Left(InvalidParamsFailure());
    }
    return await repository.updatePost(params.post, params.id);
  }
}

class UpdatePostParams {
  final UpdatePostEntity post;
  final String id;

  UpdatePostParams({required this.post, required this.id});
}