import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';

abstract class PublicationRepository {
  Future<Either<Failure, GetPublicationEntity>> getPublication(String id);
}
