import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/visitior_profile/domain/entity/another_user_profile_entity.dart';
import 'package:list_in/features/visitior_profile/domain/entity/another_user_publications_entity.dart';

abstract class AnotherUserProfileRepository {
  Future<Either<Failure, AnotherUserProfileEntity>> getUserData(String? userId);
  Future<Either<Failure, AnotherUserPublicationsEntity>> getUserPublications({
    required int page,
    required int size,
    required String userId,
  });
  Future<Either<Failure, AnotherUserProfileEntity>> followUser(
      String userId, bool follow);
  Future<Either<Failure, void>> likePublication(
      String publicationId, bool like);
  Future<Either<Failure, void>> viewPublication(
      String publicationId);
}
