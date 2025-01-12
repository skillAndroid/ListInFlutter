import 'package:equatable/equatable.dart';
import 'package:list_in/features/profile/domain/entity/publication/publication_entity.dart';

class UserPublicationsState extends Equatable {
  final List<PublicationEntity> publications;
  final bool isLoading;
  final String? error;
  final bool hasReachedEnd;
  final int currentPage;
  final bool isInitialLoading; // New field to track initial load state

  const UserPublicationsState({
    this.publications = const [],
    this.isLoading = false,
    this.error,
    this.hasReachedEnd = false,
    this.currentPage = 0,
    this.isInitialLoading = false,
  });

  UserPublicationsState copyWith({
    List<PublicationEntity>? publications,
    bool? isLoading,
    String? error,
    bool? hasReachedEnd,
    int? currentPage,
    bool? isInitialLoading,
  }) {
    return UserPublicationsState(
      publications: publications ?? this.publications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
    );
  }

  @override
  List<Object?> get props => [
        publications,
        isLoading,
        error,
        hasReachedEnd,
        currentPage,
        isInitialLoading,
      ];
}