import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/profile/data/sources/user_publications_remote.dart';
import 'package:list_in/features/profile/domain/entity/publication/paginated_publications_entity.dart';
import 'package:list_in/features/profile/domain/entity/publication/update_post_entity.dart';
import 'package:list_in/features/profile/domain/repository/user_publications_repository.dart';

class UserPublicationsRepositoryImpl implements UserPublicationsRepository {
  final UserPublicationsRemoteDataSource remoteDataSource;

  UserPublicationsRepositoryImpl({
    required this.remoteDataSource,
  });
//
  @override
  Future<Either<Failure, PaginatedPublicationsEntity>> getUserPublications({
    required int page,
    required int size,
  }) async {
    try {
      final remoteData = await remoteDataSource.getUserPublications(
        page: page,
        size: size,
      );

      debugPrint(
          'Repository received data: ${remoteData.content.length} items');

      final entity = remoteData.toEntity();
      debugPrint('Converted to entity: ${entity.content.length} items');

      return Right(entity);
    } on ServerExeption catch (e) {
      debugPrint('Server exception in repository: ${e.message}');
      return Left(ServerFailure());
    } on NetworkFailure {
      return Left(NetworkFailure());
    } catch (e, stackTrace) {
      debugPrint('Unexpected error in repository: $e');
      debugPrint('Stack trace: $stackTrace');
      return Left(ServerFailure());
    }
  }

   @override
  Future<Either<Failure, PaginatedPublicationsEntity>> getUserLikedPublications({
    required int page,
    required int size,
  }) async {
    try {
      final remoteData = await remoteDataSource.getUserLikedPublications(
        page: page,
        size: size,
      );

      debugPrint(
          'Repository received data: ${remoteData.content.length} items');

      final entity = remoteData.toEntity();
      debugPrint('Converted to entity: ${entity.content.length} items');

      return Right(entity);
    } on ServerExeption catch (e) {
      debugPrint('Server exception in repository: ${e.message}');
      return Left(ServerFailure());
    } on NetworkFailure {
      return Left(NetworkFailure());
    } catch (e, stackTrace) {
      debugPrint('Unexpected error in repository: $e');
      debugPrint('Stack trace: $stackTrace');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updatePost(
      UpdatePostEntity post, String id) async {
    try {
      await remoteDataSource.updatePublication(
          post.toModel(), id); // Убрали ненужный return
      return Right(null); // Возвращаем `Right(null)`, так как метод void
    } on ServerExeption catch (e) {
      debugPrint('Server exception in repository: ${e.message}');
      return Left(ServerFailure());
    } on NetworkFailure {
      return Left(NetworkFailure());
    } catch (e, stackTrace) {
      debugPrint('Unexpected error in repository: $e');
      debugPrint('Stack trace: $stackTrace');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String id) async {
    try {
      await remoteDataSource.deletePublication(id);
      return Right(null);
    } on ServerExeption catch (e) {
      debugPrint('Server exception in repository: ${e.message}');
      return Left(ServerFailure());
    } on NetworkFailure {
      return Left(NetworkFailure());
    } catch (e, stackTrace) {
      debugPrint('Unexpected error in repository: $e');
      debugPrint('Stack trace: $stackTrace');
      return Left(ServerFailure());
    }
  }
}
