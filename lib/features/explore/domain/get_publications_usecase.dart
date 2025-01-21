import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/domain/repository/get_publications_repository.dart';

class GetPublicationsParams {
  final String? query;
  final int? page;
  final int? size;
  final bool? bargain;
  final String? condition;
  final double? priceFrom;
  final double? priceTo;
  final String? categoryId;
  final String? subcategoryId;
  final List<String>? filters;

  GetPublicationsParams(
      {this.query,
      this.page,
      this.size,
      this.bargain,
      this.condition,
      this.priceFrom,
      this.priceTo,
      this.categoryId,
      this.subcategoryId,
      this.filters});
}

class GetPublicationsUsecase
    extends UseCase2<List<GetPublicationEntity>, GetPublicationsParams> {
  final PublicationsRepository repository;

  GetPublicationsUsecase(this.repository);

  @override
  Future<Either<Failure, List<GetPublicationEntity>>> call(
      {GetPublicationsParams? params}) {
    return repository.getPublications(
      query: params?.query,
      page: params?.page,
      size: params?.size,
      bargain: params?.bargain,
      condition: params?.condition,
      priceFrom: params?.priceFrom,
      priceTo: params?.priceTo,
      categoryId: params?.categoryId,
      subcategoryId: params?.subcategoryId,
      filters: params?.filters,
    );
  }
}
