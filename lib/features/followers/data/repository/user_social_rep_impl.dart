import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/followers/data/models/user_follow_followers_data_model.dart';
import 'package:list_in/features/followers/data/source/user_social_remoute.dart';
import 'package:list_in/features/followers/domain/entity/user_followings_followers_data.dart';
import 'package:list_in/features/followers/domain/repository/user_social_repository.dart';

class UserSocialRepositoryImpl implements UserSocialRepository {
  final UserSocialRemoteDataSource remoteDataSource;

  UserSocialRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PaginatedResponse<UserProfile>> getFollowings(String userId,
      {int page = 0, int size = 30}) async {
    try {
      final remoteResponse =
          await remoteDataSource.getFollowings(userId, page: page, size: size);
      return remoteResponse.toEntity<UserProfile>(
          (model) => (model as UserProfileModel).toEntity());
    } catch (e) {
      throw ServerFailure();
    }
  }

  @override
  Future<PaginatedResponse<UserProfile>> getFollowers(String userId,
      {int page = 0, int size = 30}) async {
    try {
      final remoteResponse =
          await remoteDataSource.getFollowers(userId, page: page, size: size);
      return remoteResponse.toEntity<UserProfile>(
          (model) => (model as UserProfileModel).toEntity());
    } catch (e) {
      throw ServerFailure();
    }
  }
}
