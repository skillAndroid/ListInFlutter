import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/visitior_profile/domain/entity/another_user_profile_entity.dart';

enum AnotherUserProfileStatus { initial, loading, success, failure }

class AnotherUserProfileState {
  final AnotherUserProfileStatus status;
  final AnotherUserProfileEntity? profile;
  final List<GetPublicationEntity> publications;
  final String? errorMessage;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final bool isFollowingInProgress;
  final int currentPage;
  final int totalElements;

  AnotherUserProfileState({
    this.status = AnotherUserProfileStatus.initial,
    this.profile,
    this.isFollowingInProgress = false,
    this.publications = const [],
    this.errorMessage,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.currentPage = 0,
    this.totalElements = 0,
  });

  AnotherUserProfileState copyWith({
    bool? isFollowingInProgress,
    AnotherUserProfileStatus? status,
    AnotherUserProfileEntity? profile,
    List<GetPublicationEntity>? publications,
    String? errorMessage,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    int? currentPage,
    int? totalElements,
  }) {
    return AnotherUserProfileState(
      isFollowingInProgress:
          isFollowingInProgress ?? this.isFollowingInProgress,
      status: status ?? this.status,
      profile: profile ?? this.profile,
      publications: publications ?? this.publications,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
      totalElements: totalElements ?? this.totalElements,
    );
  }
}
