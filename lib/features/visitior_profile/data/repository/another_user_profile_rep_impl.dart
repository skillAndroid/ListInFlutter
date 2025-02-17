import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/network/network_info.dart';
import 'package:list_in/features/visitior_profile/data/source/another_user_profile_remoute.dart';
import 'package:list_in/features/visitior_profile/domain/entity/another_user_profile_entity.dart';
import 'package:list_in/features/visitior_profile/domain/entity/another_user_publications_entity.dart';
import 'package:list_in/features/visitior_profile/domain/repository/another_user_profile_repository.dart';

class AnotherUserProfileRepImpl implements AnotherUserProfileRepository {
  final AnotherUserProfileRemoute remoteDataSource;
  final NetworkInfo networkInfo;

  AnotherUserProfileRepImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AnotherUserProfileEntity>> followUser(
    String userId,
    bool follow,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.followUser(
        userId,
        follow,
      );
      return Right(result.toEntity());
    } on ServerExeption {
      return Left(ServerFailure());
    } on NetworkFailure {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AnotherUserProfileEntity>> getUserData(
      String? userId) async {
    debugPrint('📡 Checking network connection...');
    if (!await networkInfo.isConnected) {
      debugPrint('❌ No network connection');
      return Left(NetworkFailure());
    }

    try {
      debugPrint('🔄 Fetching user data from remote source...');
      final remoteData = await remoteDataSource.getUserData(userId);
      debugPrint('📦 Remote data received: $remoteData');

      final entity = remoteData.toEntity();
      debugPrint('🔄 Converted to entity: $entity');

      return Right(entity);
    } on ServerExeption catch (e) {
      debugPrint('❌ ServerException: $e');
      return Left(ServerFailure());
    } on ConnectionExeption catch (e) {
      debugPrint('❌ ConnectionException: $e');
      return Left(NetworkFailure());
    } on ConnectiontTimeOutExeption catch (e) {
      debugPrint('❌ ConnectionTimeOutException: $e');
      return Left(NetworkFailure());
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AnotherUserPublicationsEntity>> getUserPublications(
      {required int page, required int size, required String userId}) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final remoteData = await remoteDataSource.getPublications(
        page: page,
        size: size,
        userId: userId,
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
  Future<Either<Failure, void>> likePublication(
      String publicationId, bool like) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.likePublication(
        publicationId,
        like,
      );
      debugPrint('😘😘Success liking in repository impl!');
      return Right(result);
    } on ServerExeption {
      return Left(ServerFailure());
    } on NetworkFailure {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
