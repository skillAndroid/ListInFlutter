import 'package:equatable/equatable.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';

enum PublicationUpdatingState {
  initial,
  uploadingImages,
  uploadingVideo,
  updatingPublication,
  success,
  error
}

class UserPublicationsState extends Equatable {
  final List<GetPublicationEntity> publications;
  final bool isLoading;
  final String? error;
  final bool hasReachedEnd;
  final bool isRefreshing;
  final int currentPage;
  final bool isInitialLoading;
  final Set<String> deletedPublicationIds; // Add this field

  const UserPublicationsState({
    this.publications = const [],
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
    this.hasReachedEnd = false,
    this.currentPage = 0,
    this.isInitialLoading = false,
    this.deletedPublicationIds = const {},
  });

  UserPublicationsState copyWith({
    List<GetPublicationEntity>? publications,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool? hasReachedEnd,
    int? currentPage,
    bool? isInitialLoading,
    Set<String>? deletedPublicationIds,
  }) {
    return UserPublicationsState(
      publications: publications ?? this.publications,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing, // Add this
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      deletedPublicationIds:
          deletedPublicationIds ?? this.deletedPublicationIds,
    );
  }

  @override
  List<Object?> get props => [
        publications,
        isLoading,
        isRefreshing, // Add this
        hasReachedEnd,
        currentPage,
        error,
        isInitialLoading,
      ];
}
