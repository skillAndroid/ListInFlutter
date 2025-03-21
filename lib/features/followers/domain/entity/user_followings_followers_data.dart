// 1. Entities
class UserProfile {
  final String userId;
  final String nickName;
  final String profileImagePath;
  final int following;
  final int followers;
  final bool isFollowing;

  UserProfile({
    required this.userId,
    required this.nickName,
    required this.profileImagePath,
    required this.isFollowing,
    required this.followers,
    required this.following,
  });
}

class PaginatedResponse<T> {
  final int totalElements;
  final int totalPages;
  final int size;
  final List<T> content;
  final int number;
  final bool first;
  final bool last;

  PaginatedResponse({
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.content,
    required this.number,
    required this.first,
    required this.last,
  });
}
