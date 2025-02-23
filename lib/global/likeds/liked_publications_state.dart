// State
import 'package:equatable/equatable.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';

class LikedPublicationsState extends Equatable {
  final List<GetPublicationEntity> publications;
  final bool isLoading;
  final bool isRefreshing;
  final bool hasReachedEnd;
  final int currentPage;
  final String? error;
  final bool isInitialLoading;

  const LikedPublicationsState({
    this.publications = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.hasReachedEnd = false,
    this.currentPage = 0,
    this.error,
    this.isInitialLoading = true,
  });

  LikedPublicationsState copyWith({
    List<GetPublicationEntity>? publications,
    bool? isLoading,
    bool? isRefreshing,
    bool? hasReachedEnd,
    int? currentPage,
    String? error,
    bool? isInitialLoading,
  }) {
    return LikedPublicationsState(
      publications: publications ?? this.publications,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
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
        isRefreshing,
        hasReachedEnd,
        currentPage,
        error,
        isInitialLoading,
      ];
}