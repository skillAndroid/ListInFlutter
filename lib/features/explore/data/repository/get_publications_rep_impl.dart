import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/explore/data/source/get_publications_remoute.dart';
import 'package:list_in/features/explore/domain/enties/filter_prediction_values_entity.dart';
import 'package:list_in/features/explore/domain/enties/prediction_entity.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/domain/repository/get_publications_repository.dart';
import 'package:list_in/features/profile/domain/entity/publication/paginated_publications_entity.dart';

class PublicationsRepositoryImpl implements PublicationsRepository {
  final PublicationsRemoteDataSource remoteDataSource;

  PublicationsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, PaginatedPublicationsEntity>>
      getPublicationsFiltered2({
    String? categoryId,
    String? subcategoryId,
    String? sellerType,
    bool? isFree,
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
    try {
      final publications = await remoteDataSource.getPublications(
        isFree: isFree,
        sellerType: sellerType,
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

  @override
  Future<Either<Failure, List<PredictionEntity>>> getPredictions(
      String? query) async {
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
  }

  @override
  Future<Either<Failure, FilterPredictionValuesEntity>>
      getFilteredValuesOfPublications({
    String? categoryId,
    String? subcategoryId,
    String? sellerType,
    bool? isFree,
    String? locationIds,
    String? query,
    bool? bargain,
    String? condition,
    double? priceFrom,
    double? priceTo,
    List<String>? filters,
    List<String>? numeric,
    CancelToken? cancelToken,
  }) async {
    debugPrint('🚀 Starting getFilteredValuesOfPublications with params:');
    debugPrint('categoryId: $categoryId');
    debugPrint('subcategoryId: $subcategoryId');
    debugPrint('sellerType: $sellerType');
    debugPrint('isFree: $isFree');
    debugPrint('query: $query');
    debugPrint('bargain: $bargain');
    debugPrint('condition: $condition');
    debugPrint('priceFrom: $priceFrom');
    debugPrint('priceTo: $priceTo');
    debugPrint('filters: $filters');
    debugPrint('numeric: $numeric');
    debugPrint('locationIds: $locationIds');

    debugPrint('📶 Network is connected');
    try {
      debugPrint('📤 Making API request...');
      final filterPredictionValues =
          await remoteDataSource.getFilteredValuesOfPublications(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        isFree: isFree,
        sellerType: sellerType,
        query: query,
        bargain: bargain,
        condition: condition,
        priceFrom: priceFrom,
        priceTo: priceTo,
        filters: filters,
        numeric: numeric,
        locationIds: locationIds,
        cancelToken: cancelToken,
      );

      debugPrint(
          '📥 Received foundPublications response: ${filterPredictionValues.foundPublications}');
      debugPrint(
          '📥 Received foundPublications priceFrom: ${filterPredictionValues.priceFrom}');
      debugPrint(
          '📥 Received foundPublications priceTo: ${filterPredictionValues.priceTo}');
      try {
        final entity = filterPredictionValues.toEntity();
        debugPrint('✅ Successfully parsed response to entity:');
        debugPrint('Parsed fields:');

        return Right(entity);
      } catch (parseError) {
        debugPrint('❌ Error during parsing: $parseError');
        debugPrint(
            'Raw data that failed parsing: ${filterPredictionValues.toString()}');
        rethrow;
      }
    } on ServerExeption catch (e) {
      debugPrint('⚠️ Server Exception: ${e.toString()}');
      return Left(ServerFailure());
    } on ConnectionExeption catch (e) {
      debugPrint('⚠️ Connection Exception: ${e.toString()}');
      return Left(NetworkFailure());
    } catch (e) {
      debugPrint('⚠️ Unexpected Exception: ${e.toString()}');
      debugPrint('Stack trace: ${StackTrace.current}');
      return Left(UnexpectedFailure());
    }
  }
}
