import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';

abstract class PublicationsRepository {
  Future<Either<Failure, List<GetPublicationEntity>>> getPublications({
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
  });

  Future<Either<Failure, List<GetPublicationEntity>>> getPublicationsFiltered({
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
  });

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
  });
}
