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
    print('📡 Fetching followings for user: $userId, page: $page, size: $size');
    try {
      final remoteResponse =
          await remoteDataSource.getFollowings(userId, page: page, size: size);
      print('✅ Successfully fetched followings for user: $userId');
      return remoteResponse.toEntity<UserProfile>(
          (model) => (model as UserProfileModel).toEntity());
    } catch (e) {
      print('❌ Error fetching followings for user: $userId - $e');
      throw ServerFailure();
    }
  }

  @override
  Future<PaginatedResponse<UserProfile>> getFollowers(String userId,
      {int page = 0, int size = 30}) async {
    print('📡 Fetching followers for user: $userId, page: $page, size: $size');
    try {
      final remoteResponse =
          await remoteDataSource.getFollowers(userId, page: page, size: size);
      print('✅ Successfully fetched followers for user: $userId');
      return remoteResponse.toEntity<UserProfile>(
          (model) => (model as UserProfileModel).toEntity());
    } catch (e) {
      print('❌ Error fetching followers for user: $userId - $e');
      throw ServerFailure();
    }
  }
}
