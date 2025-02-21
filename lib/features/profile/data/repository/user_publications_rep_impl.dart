import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/network/network_info.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/profile/data/sources/user_publications_remote.dart';
import 'package:list_in/features/profile/domain/entity/publication/paginated_publications_entity.dart';
import 'package:list_in/features/profile/domain/entity/publication/update_post_entity.dart';
import 'package:list_in/features/profile/domain/repository/user_publications_repository.dart';

class UserPublicationsRepositoryImpl implements UserPublicationsRepository {
  final UserPublicationsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserPublicationsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedPublicationsEntity>> getUserPublications({
    required int page,
    required int size,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

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
  Future<Either<Failure, GetPublicationEntity>> updatePost(
      UpdatePostEntity post, String id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    try {
      final result =
          await remoteDataSource.updatePublication(post.toModel(), id);
      return Right(result.toEntity());
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
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
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
