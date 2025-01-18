import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';

abstract class PublicationsRepository {
  Future<Either<Failure, List<GetPublicationEntity>>> getPublications({
    String? query,
    int? page,
    int? size,
    bool? bargain,
    String? condition,
    double? priceFrom,
    double? priceTo,
  });
}


