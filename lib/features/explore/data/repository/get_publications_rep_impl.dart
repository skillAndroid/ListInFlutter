import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/network/network_info.dart';
import 'package:list_in/features/explore/data/source/get_publications_remoute.dart';
import 'package:list_in/features/explore/domain/enties/filter_prediction_values_entity.dart';
import 'package:list_in/features/explore/domain/enties/prediction_entity.dart';
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
  Future<Either<Failure, List<PublicationPairEntity>>>
      getPublicationsFiltered2({
    String? categoryId,
    String? subcategoryId,
    String? query,
    int? page,
    int? size,
    bool? bargain,
    String? condition,
    double? priceFrom,
    double? priceTo,
    List<String>? filters,
    List<String>? numeric,
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
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          filters: filters,
          numeric: numeric,
        );
        return Right(
          publications.map((pair) => pair.toEntity()).toList(),
        );
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

  @override
  Future<Either<Failure, List<PredictionEntity>>> getPredictions(
      String? query) async {
    if (await networkInfo.isConnected) {
      try {
        final publications = await remoteDataSource.getPredictions(query);
        return Right(
          publications.map((model) => model.toEntity()).toList(),
        );
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

  @override
  Future<Either<Failure, VideoPublicationsEntity>> getVideoPublications({
    String? categoryId,
    String? subcategoryId,
    String? query,
    int? page,
    int? size,
    bool? bargain,
    String? condition,
    double? priceFrom,
    double? priceTo,
    List<String>? filters,
    List<String>? numeric,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final publications = await remoteDataSource.getVideoPublications(
          query: query,
          page: page,
          size: size,
          bargain: bargain,
          condition: condition,
          priceFrom: priceFrom,
          priceTo: priceTo,
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          filters: filters,
        );
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
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, FilterPredictionValuesEntity>>
      getFilteredValuesOfPublications({
    String? query,
    int? page,
    int? size,
    bool? bargain,
    String? condition,
    double? priceFrom,
    double? priceTo,
    List<String>? filters,
    List<String>? numeric,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final filterPredictionValues =
            await remoteDataSource.getFilteredValuesOfPublications(
          query: query,
          page: page,
          size: size,
          bargain: bargain,
          condition: condition,
          priceFrom: priceFrom,
          priceTo: priceTo,
          filters: filters,
          numeric: numeric,
        );
        return Right(filterPredictionValues.toEntity());
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
