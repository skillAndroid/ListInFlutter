import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/auth/domain/entities/auth_tokens.dart';
import 'package:list_in/features/profile/domain/entity/user/user_data_entity.dart';
import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, List<String>>> uploadImages(List<XFile> images);
  Future<Either<Failure, (UserDataEntity, AuthToken?)>> updateUserData(UserProfileEntity user);
  Future<Either<Failure, UserDataEntity>> getUserData();
}