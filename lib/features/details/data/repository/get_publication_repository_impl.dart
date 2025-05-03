import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/details/data/source/remoute_fetch_publication.dart';
import 'package:list_in/features/details/domain/repository/get_publication_repository.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';

class PublicationRepositoryImpl implements PublicationRepository {
  RemouteFetchPublication remoteDataSource;

  PublicationRepositoryImpl({required this.remoteDataSource});
  @override
  Future<Either<Failure, GetPublicationEntity>> getPublication(
    String id,
  ) async {
    print('some user id in the RepIMPL $id');
    try {
      final publications = await remoteDataSource.getPublication(id);
      return Right(
        publications.toEntity(),
      );
    } on ServerExeption {
      return Left(ServerFailure());
    } on ConnectionExeption {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}
