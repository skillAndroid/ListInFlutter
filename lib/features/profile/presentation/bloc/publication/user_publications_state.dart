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

class PublicationUpdateState extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final bool canBargain;
  final String condition;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;
  final bool isSuccess;

  const PublicationUpdateState({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.canBargain,
    required this.condition,
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
    this.isSuccess = false,
  });

  factory PublicationUpdateState.initial() => const PublicationUpdateState(
        id: '',
        title: '',
        description: '',
        price: 0.0,
        canBargain: false,
        condition: 'NEW_PRODUCT',
      );

  PublicationUpdateState copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    bool? canBargain,
    String? condition,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
    bool? isSuccess,
  }) {
    return PublicationUpdateState(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      canBargain: canBargain ?? this.canBargain,
      condition: condition ?? this.condition,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        canBargain,
        condition,
        isLoading,
        error,
        isSubmitting,
        isSuccess,
      ];
}
