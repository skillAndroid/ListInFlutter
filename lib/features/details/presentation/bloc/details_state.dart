import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/visitior_profile/domain/entity/another_user_profile_entity.dart';

enum DetailsStatus { initial, loading, success, failure }

class DetailsState {
  final DetailsStatus status;
  final AnotherUserProfileEntity? profile;
  final List<GetPublicationEntity> publications;
  final String? errorMessage;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final bool isFollowingInProgress;
  final int currentPage;
  final int totalElements;
  final GetPublicationEntity? singlePublication; // New field
  final bool isLoadingSinglePublication; // New field

  DetailsState({
    this.status = DetailsStatus.initial,
    this.profile,
    this.isFollowingInProgress = false,
    this.publications = const [],
    this.errorMessage,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.currentPage = 0,
    this.totalElements = 0,
    this.singlePublication, // New field
    this.isLoadingSinglePublication = false, // New field
  });

  DetailsState copyWith({
    bool? isFollowingInProgress,
    DetailsStatus? status,
    AnotherUserProfileEntity? profile,
    List<GetPublicationEntity>? publications,
    String? errorMessage,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    int? currentPage,
    int? totalElements,
    GetPublicationEntity? singlePublication, // New parameter
    bool? isLoadingSinglePublication, // New parameter
  }) {
    return DetailsState(
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
      singlePublication: singlePublication ?? this.singlePublication,
      isLoadingSinglePublication:
          isLoadingSinglePublication ?? this.isLoadingSinglePublication,
    );
  }
}
