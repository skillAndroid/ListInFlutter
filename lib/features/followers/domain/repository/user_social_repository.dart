// 2. Repository Interface
import 'package:list_in/features/followers/domain/entity/user_followings_followers_data.dart';

abstract class UserSocialRepository {
  Future<PaginatedResponse<UserProfile>> getFollowings(String userId, {int page = 0, int size = 5});
  Future<PaginatedResponse<UserProfile>> getFollowers(String userId, {int page = 0, int size = 5});
}