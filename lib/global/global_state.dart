import 'package:equatable/equatable.dart';
import 'package:list_in/global/global_status.dart';

class GlobalState extends Equatable {
  final Map<String, FollowStatusInfo> followStatusMap;
  final Set<String> followedUserIds;
  final Map<String, ViewStatusInfo> viewStatusMap;
  final Set<String> viewedPublicationsIds;
  final Map<String, LikeStatusInfo> likeStatusMap;
  final Set<String> likedPublicationIds;
  final Map<String, int> userFollowersCount;
  final Map<String, int> userFollowingCount;

  const GlobalState({
    this.followStatusMap = const {},
    this.followedUserIds = const {},
    this.likeStatusMap = const {},
    this.likedPublicationIds = const {},
    this.userFollowersCount = const {},
    this.userFollowingCount = const {},
    this.viewStatusMap = const {},
    this.viewedPublicationsIds = const {},
  });

  bool isUserFollowed(String userId) => followedUserIds.contains(userId);
  bool isPublicationViewed(String publicationId) =>
      viewedPublicationsIds.contains(publicationId);

  ViewStatus getViewStatus(String publicationId) =>
      viewStatusMap[publicationId]?.status ?? ViewStatus.initial;
  FollowStatus getFollowStatus(String userId) =>
      followStatusMap[userId]?.status ?? FollowStatus.initial;
  int getFollowersCount(String userId) => userFollowersCount[userId] ?? 0;
  int getFollowingCount(String userId) => userFollowingCount[userId] ?? 0;

  bool isPublicationLiked(String publicationId) =>
      likedPublicationIds.contains(publicationId);

  LikeStatus getLikeStatus(String publicationId) =>
      likeStatusMap[publicationId]?.status ?? LikeStatus.initial;

  GlobalState copyWith({
    Map<String, FollowStatusInfo>? followStatusMap,
    Set<String>? followedUserIds,
    Map<String, int>? userFollowersCount,
    Map<String, int>? userFollowingCount,
    Map<String, LikeStatusInfo>? likeStatusMap,
    Set<String>? likedPublicationIds,
    Map<String, ViewStatusInfo>? viewStatusMap,
    Set<String>? viewedPublicationIds,
  }) {
    return GlobalState(
      followStatusMap: followStatusMap ?? this.followStatusMap,
      followedUserIds: followedUserIds ?? this.followedUserIds,
      userFollowersCount: userFollowersCount ?? this.userFollowersCount,
      userFollowingCount: userFollowingCount ?? this.userFollowingCount,
      likeStatusMap: likeStatusMap ?? this.likeStatusMap,
      likedPublicationIds: likedPublicationIds ?? this.likedPublicationIds,
      viewStatusMap: viewStatusMap ?? this.viewStatusMap,
      viewedPublicationsIds: viewedPublicationIds ?? this.viewedPublicationsIds,
    );
  }

  @override
  List<Object> get props => [
        followStatusMap,
        followedUserIds,
        userFollowersCount,
        userFollowingCount,
        likeStatusMap,
        likedPublicationIds,
        viewStatusMap,
        viewedPublicationsIds,
      ];
}
