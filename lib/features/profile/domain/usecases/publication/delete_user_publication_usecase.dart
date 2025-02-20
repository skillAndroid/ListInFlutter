import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/profile/domain/repository/user_publications_repository.dart';

class DeleteUserPublicationUsecase extends UseCase2<void, DeleteParams> {
  final UserPublicationsRepository repository;

  DeleteUserPublicationUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call({DeleteParams? params}) async {
    if (params == null) {
      return Left(InvalidParamsFailure());
    }
    return await repository.deletePost(params.id);
  }
}

class DeleteParams {
  final String id;

  DeleteParams({required this.id});
}
