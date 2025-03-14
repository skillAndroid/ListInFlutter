import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/auth/domain/entities/auth_tokens.dart';
import 'package:list_in/features/post/data/models/location_tree/location_model.dart'
    as models;
import 'package:list_in/features/profile/data/model/user/user_profile_model.dart';
import 'package:list_in/features/profile/data/sources/user_profile_location_local.dart';
import 'package:list_in/features/profile/data/sources/user_profile_remoute.dart';
import 'package:list_in/features/profile/domain/entity/user/user_data_entity.dart';
import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';
import 'package:list_in/features/profile/domain/repository/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserLocalDataSource localUserData;
  final UserProfileRemoute remoteDataSource;

  UserProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localUserData,
  });

  @override
  Future<Either<Failure, List<String>>> uploadImages(List<XFile> images) async {
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
    try {
      final userModel = UserDataModelForUpdate(
        profileImagePath: user.profileImagePath,
        nickName: user.nickName,
        phoneNumber: user.phoneNumber,
        isGrantedForPreciseLocation: user.isGrantedForPreciseLocation,
        locationName: user.locationName,
        longitude: user.longitude,
        latitude: user.latitude,
        country: user.country,
        state: user.state,
        county: user.county,
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
    try {
      debugPrint('🔄 Fetching user data from remote source...');
      final remoteData = await remoteDataSource.getUserData();
      debugPrint('📦 Remote data received: $remoteData');
      final entity = remoteData.toEntity();
      debugPrint('🔄 Converted to entity: $entity');

      // Cache the location data after successfully fetching user data
      await _cacheUserLocationFromUserData(entity);

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

  Future<void> _cacheUserLocationFromUserData(UserDataEntity userData) async {
    try {
      if (userData.country != null ||
          userData.state != null ||
          userData.county != null) {
        await localUserData.cacheUserLocation(
          country: userData.country,
          state: userData.state,
          county: userData.county,
          longitude: userData.longitude,
          latitude: userData.latitude,
          isGrantedForPreciseLocation: userData.isGrantedForPreciseLocation,
          locationName: userData.locationName,
        );
        debugPrint('✅ Location data cached successfully');
      } else {
        debugPrint('⚠️ No location data to cache');
      }
    } catch (e) {
      debugPrint('❌ Error caching location data: $e');
    }
  }

  @override
  Future<Either<Failure, void>> cacheUserLocation({
    required models.Country? country,
    required models.State? state,
    required models.County? county,
    double? longitude,
    double? latitude,
    bool? isGrantedForPreciseLocation,
    String? locationName,
  }) async {
    try {
      await localUserData.cacheUserLocation(
        country: country,
        state: state,
        county: county,
        longitude: longitude,
        latitude: latitude,
        isGrantedForPreciseLocation: isGrantedForPreciseLocation,
        locationName: locationName,
      );
      return const Right(null);
    } catch (e) {
      debugPrint('❌ Error in cacheUserLocation: $e');
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getUserLocation() async {
    try {
      final locationData = await localUserData.getUserLocation();
      return Right(locationData);
    } catch (e) {
      debugPrint('❌ Error in getUserLocation: $e');
      return Left(CacheFailure());
    }
  }
}
