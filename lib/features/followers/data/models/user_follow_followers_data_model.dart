import 'package:list_in/features/followers/domain/entity/user_followings_followers_data.dart';

class UserProfileModel {
  final String userId;
  final String nickName;
  final String profileImagePath;
  final int following;
  final int followers;
  final bool isFollowing;

  UserProfileModel({
    required this.userId,
    required this.nickName,
    required this.profileImagePath,
    required this.isFollowing,
    required this.followers,
    required this.following,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'] ?? '',
      nickName: json['nickName'] ?? '',
      profileImagePath: json['profileImagePath'] ?? '',
      isFollowing: json['following'] ?? false,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      userId: userId,
      nickName: nickName,
      profileImagePath: profileImagePath,
      followers: followers,
      following: following,
      isFollowing: isFollowing,
    );
  }
}

class PaginatedResponseModel<T> {
  final int totalElements;
  final int totalPages;
  final int size;
  final List<dynamic> content;
  final int number;

  final bool first;
  final bool last;

  PaginatedResponseModel({
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.content,
    required this.number,
    required this.first,
    required this.last,
  });

  factory PaginatedResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    var contentList = (json['content'] as List?)
            ?.map((item) => fromJsonT(item as Map<String, dynamic>))
            .toList() ??
        [];

    // This is handling sort differently based on the actual response structure

    return PaginatedResponseModel<T>(
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      size: json['size'] ?? 0,
      content: contentList,
      number: json['number'] ?? 0,
      first: json['first'] ?? false,
      last: json['last'] ?? false,
    );
  }
  PaginatedResponse<R> toEntity<R>(R Function(dynamic) mapper) {
    return PaginatedResponse<R>(
      totalElements: totalElements,
      totalPages: totalPages,
      size: size,
      content: content.map((e) => mapper(e)).toList(),
      number: number,
      first: first,
      last: last,
    );
  }
}
