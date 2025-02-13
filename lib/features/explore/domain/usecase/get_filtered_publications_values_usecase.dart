import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/explore/domain/enties/filter_prediction_values_entity.dart';
import 'package:list_in/features/explore/domain/repository/get_publications_repository.dart';

class GetFilteredPublicationsValuesParams {
  final String? query;
  final bool? bargain;
  final String? condition;
  final double? priceFrom;
  final double? priceTo;

  final List<String>? filters;
  final List<String>? numerics;
  final CancelToken? cancelToken;

  GetFilteredPublicationsValuesParams({
    this.query,
    this.bargain,
    this.condition,
    this.priceFrom,
    this.priceTo,
    this.filters,
    this.numerics,
    this.cancelToken,
  });
}

class GetFilteredPublicationsValuesUsecase extends UseCase2<
    FilterPredictionValuesEntity, GetFilteredPublicationsValuesParams> {
  final PublicationsRepository repository;

  GetFilteredPublicationsValuesUsecase(this.repository);

  @override
  Future<Either<Failure, FilterPredictionValuesEntity>> call(
      {GetFilteredPublicationsValuesParams? params}) {
    return repository.getFilteredValuesOfPublications(
      query: params?.query,
      bargain: params?.bargain,
      condition: params?.condition,
      priceFrom: params?.priceFrom,
      priceTo: params?.priceTo,
      filters: params?.filters,
      numeric: params?.numerics,
      cancelToken: params?.cancelToken,
    );
  }
}
