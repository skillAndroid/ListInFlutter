import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/domain/repository/get_publications_repository.dart';
import 'package:list_in/features/profile/domain/entity/publication/paginated_publications_entity.dart';

class GetPublicationsParams {
  final String? sellerType;
  final bool? isFree;
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
  final List<String>? numerics;

  GetPublicationsParams({
    this.sellerType,
    this.isFree,
    this.query,
    this.page,
    this.size,
    this.bargain,
    this.condition,
    this.priceFrom,
    this.priceTo,
    this.categoryId,
    this.subcategoryId,
    this.filters,
    this.numerics,
  });
}

class GetPublicationsUsecase
    extends UseCase2<PaginatedPublicationsEntity, GetPublicationsParams> {
  final PublicationsRepository repository;

  GetPublicationsUsecase(this.repository);

  @override
  Future<Either<Failure, PaginatedPublicationsEntity>> call(
      {GetPublicationsParams? params}) {
    return repository.getPublicationsFiltered2(
      query: params?.query,
      page: params?.page,
      isFree: params?.isFree,
      sellerType: params?.sellerType,
      size: params?.size,
      bargain: params?.bargain,
      condition: params?.condition,
      priceFrom: params?.priceFrom,
      priceTo: params?.priceTo,
      categoryId: params?.categoryId,
      subcategoryId: params?.subcategoryId,
      filters: params?.filters,
      numeric: params?.numerics,
    );
  }
}
