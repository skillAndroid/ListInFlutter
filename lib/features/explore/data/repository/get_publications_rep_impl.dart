import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/network/network_info.dart';
import 'package:list_in/features/explore/data/source/get_publications_remoute.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/domain/repository/get_publications_repository.dart';

class PublicationsRepositoryImpl implements PublicationsRepository {
  final PublicationsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PublicationsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<GetPublicationEntity>>> getPublications({
    String? query,
    int? page,
    int? size,
    bool? bargain,
    String? condition,
    double? priceFrom,
    double? priceTo,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final publications = await remoteDataSource.getPublications(
          query: query,
          page: page,
          size: size,
          bargain: bargain,
          condition: condition,
          priceFrom: priceFrom,
          priceTo: priceTo,
        );
        return Right(publications.map((model) => model.toEntity()).toList());
      } on ServerExeption {
        return Left(ServerFailure());
      } on ConnectionExeption {
        return Left(NetworkFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}