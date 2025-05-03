import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/details/domain/repository/get_publication_repository.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';

class GetPublicationUseCase extends UseCase2<GetPublicationEntity, String> {
  final PublicationRepository repository;

  GetPublicationUseCase({required this.repository});

  @override
  Future<Either<Failure, GetPublicationEntity>> call({String? params}) async {
    if (params == null) {
      return Left(ValidationFailure());
    }
    return await repository.getPublication(params);
  }
}
