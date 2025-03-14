import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/auth/domain/entities/auth_tokens.dart';
import 'package:list_in/features/post/data/models/location_tree/location_model.dart'
    as models;
import 'package:list_in/features/profile/domain/entity/user/user_data_entity.dart';
import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, List<String>>> uploadImages(List<XFile> images);
  Future<Either<Failure, (UserDataEntity, AuthToken?)>> updateUserData(
      UserProfileEntity user);
  Future<Either<Failure, UserDataEntity>> getUserData();

  Future<Either<Failure, void>> cacheUserLocation({
    required models.Country? country,
    required models.State? state,
    required models.County? county,
    double? longitude,
    double? latitude,
    bool? isGrantedForPreciseLocation,
    String? locationName,
  });
  Future<Either<Failure, Map<String, dynamic>?>> getUserLocation();
}
