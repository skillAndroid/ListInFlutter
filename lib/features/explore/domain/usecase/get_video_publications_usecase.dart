import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/domain/repository/get_publications_repository.dart';
import 'package:list_in/features/explore/domain/usecase/get_publications_usecase.dart';

class GetVideoPublicationsUsecase
    extends UseCase2<VideoPublicationsEntity, GetPublicationsParams> {
  final PublicationsRepository repository;

  GetVideoPublicationsUsecase(this.repository);

  @override
  Future<Either<Failure, VideoPublicationsEntity>> call(
      {GetPublicationsParams? params}) {
    return repository.getVideoPublications(
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
