import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/network/network_info.dart';
import 'package:list_in/features/auth/domain/entities/auth_tokens.dart';
import 'package:list_in/features/profile/data/model/user/user_profile_model.dart';
import 'package:list_in/features/profile/data/sources/user_profile_remoute.dart';
import 'package:list_in/features/profile/domain/entity/user/user_data_entity.dart';
import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';
import 'package:list_in/features/profile/domain/repository/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoute remoteDataSource;
  final NetworkInfo networkInfo;

  UserProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<String>>> uploadImages(List<XFile> images) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.uploadImages(images);
      return Right(result);
    } on ServerExeption {
      return Left(ServerFailure());
    } on ConnectionExeption {
      return Left(NetworkFailure());
    } on ConnectiontTimeOutExeption {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, (UserDataEntity, AuthToken?)>> updateUserData(
      UserProfileEntity user) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    try {
      final userModel = UserProfileModel(
        profileImagePath: user.profileImagePath,
        nickName: user.nickName,
        phoneNumber: user.phoneNumber,
        isGrantedForPreciseLocation: user.isGrantedForPreciseLocation,
        locationName: user.locationName,
        longitude: user.longitude,
        latitude: user.latitude,
        fromTime: user.fromTime,
        toTime: user.toTime,
        isBusinessAccount: user.isBusinessAccount,
        biography: user.biography,
      );

      final (userData, tokens) =
          await remoteDataSource.updateUserData(userModel);
      return Right((userData.toEntity(), tokens));
    } on ServerExeption {
      return Left(ServerFailure());
    } on ConnectionExeption {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserDataEntity>> getUserData() async {
    debugPrint('📡 Checking network connection...');
    if (!await networkInfo.isConnected) {
      debugPrint('❌ No network connection');
      return Left(NetworkFailure());
    }

    try {
      debugPrint('🔄 Fetching user data from remote source...');
      final remoteData = await remoteDataSource.getUserData();
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
