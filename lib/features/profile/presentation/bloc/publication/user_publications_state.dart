import 'package:equatable/equatable.dart';
import 'package:list_in/features/profile/domain/entity/publication/publication_entity.dart';

enum PublicationUpdatingState {
  initial,
  uploadingImages,
  uploadingVideo,
  updatingPublication,
  success,
  error
}

class UserPublicationsState extends Equatable {
  final List<PublicationEntity> publications;
  final bool isLoading;
  final String? error;
  final bool hasReachedEnd;
  final bool isRefreshing;
  final int currentPage;
  final bool isInitialLoading;

  const UserPublicationsState({
    this.publications = const [],
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
    this.hasReachedEnd = false,
    this.currentPage = 0,
    this.isInitialLoading = false,
  });

  UserPublicationsState copyWith({
    List<PublicationEntity>? publications,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool? hasReachedEnd,
    int? currentPage,
    bool? isInitialLoading,
  }) {
    return UserPublicationsState(
      publications: publications ?? this.publications,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing, // Add this
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
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
