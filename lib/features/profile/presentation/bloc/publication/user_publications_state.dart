import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
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
  final List<String>? imageUrls;
  final String? videoUrl;
  final List<XFile> newImages;
  final XFile? newVideo;
  final bool isVideoPlaying;
  final PublicationUpdatingState updatingState;
  final bool hasDeletedVideo;
  final List<String> deletedImageUrls;
  final Map<String, List<String>> originalImageUrls;
  final Map<String, String?> originalVideoUrl;

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
    this.imageUrls = const [],
    this.videoUrl,
    this.newImages = const [],
    this.newVideo,
    this.isVideoPlaying = false,
    this.updatingState = PublicationUpdatingState.initial,
    this.hasDeletedVideo = false,
    this.deletedImageUrls = const [],
    this.originalImageUrls = const {},
    this.originalVideoUrl = const {},
  });

  factory PublicationUpdateState.initial() => const PublicationUpdateState(
        id: '',
        title: '',
        description: '',
        price: 0.0,
        canBargain: false,
        condition: 'NEW_PRODUCT',
        newImages: [],
        imageUrls: [],
        deletedImageUrls: [],
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
    List<String>? imageUrls,
    String? videoUrl,
    List<XFile>? newImages,
    XFile? newVideo,
    bool? isVideoPlaying,
    PublicationUpdatingState? updatingState,
    bool? hasDeletedVideo,
    List<String>? deletedImageUrls,
    Map<String, List<String>>? originalImageUrls,
    Map<String, String?>? originalVideoUrl,
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
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: hasDeletedVideo == true ? null : (videoUrl ?? this.videoUrl),
      newImages: newImages ?? this.newImages,
      newVideo: hasDeletedVideo == true ? null : (newVideo ?? this.newVideo),
      isVideoPlaying: isVideoPlaying ?? this.isVideoPlaying,
      updatingState: updatingState ?? this.updatingState,
      hasDeletedVideo: hasDeletedVideo ?? this.hasDeletedVideo,
      deletedImageUrls: deletedImageUrls ?? this.deletedImageUrls,
      originalImageUrls: originalImageUrls ?? this.originalImageUrls,
      originalVideoUrl: originalVideoUrl ?? this.originalVideoUrl,
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
        imageUrls,
        videoUrl,
        newImages,
        newVideo,
        isVideoPlaying,
        updatingState,
        hasDeletedVideo,
        deletedImageUrls,
        originalImageUrls,
        originalVideoUrl,
      ];
}
