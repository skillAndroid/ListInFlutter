import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/visitior_profile/domain/entity/another_user_profile_entity.dart';

abstract class AnotherUserProfileRepository {
  Future<Either<Failure, AnotherUserProfileEntity>> getUserData(String? userId);
}
