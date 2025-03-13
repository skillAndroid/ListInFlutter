import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/explore/domain/enties/filter_prediction_values_entity.dart';
import 'package:list_in/features/explore/domain/enties/prediction_entity.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/profile/domain/entity/publication/paginated_publications_entity.dart';

abstract class PublicationsRepository {
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
    String? locationIds,
  });

  Future<Either<Failure, List<PredictionEntity>>> getPredictions(String? query);

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
  });

  Future<Either<Failure, FilterPredictionValuesEntity>>
      getFilteredValuesOfPublications({
    String? categoryId,
    String? subcategoryId,
    String? sellerType,
    bool? isFree,
    String? query,
    bool? bargain,
    String? condition,
    double? priceFrom,
    double? priceTo,
    String? locationIds,
    List<String>? filters,
    List<String>? numeric,
    CancelToken? cancelToken,
  });
}
