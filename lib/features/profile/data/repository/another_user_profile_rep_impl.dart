import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/network/network_info.dart';
import 'package:list_in/features/profile/data/sources/another_user_profile_remoute.dart';
import 'package:list_in/features/profile/domain/entity/another_user/another_user_profile_entity.dart';
import 'package:list_in/features/profile/domain/repository/another_user_profile_repository.dart';

class AnotherUserProfileRepImpl implements AnotherUserProfileRepository {
  final AnotherUserProfileRemoute remoteDataSource;
  final NetworkInfo networkInfo;

  AnotherUserProfileRepImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

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
}
