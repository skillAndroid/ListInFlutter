import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/visitior_profile/domain/repository/another_user_profile_repository.dart';

class ViewPublicationUsecase extends UseCase2<void, ViewParams> {
  final AnotherUserProfileRepository repository;

  ViewPublicationUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call({ViewParams? params}) async {
    if (params == null) return Left(ValidationFailure());
    return await repository.viewPublication(
      params.publicationId,
    );
  }
}

class ViewParams {
  final String publicationId;

  ViewParams({
    required this.publicationId,
  });
}
