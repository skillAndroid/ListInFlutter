// global_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_event.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/follow_usecase.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/like_publication_usecase.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/view_publication_usecase.dart';

enum FollowStatus { initial, inProgress, success, error }

enum LikeStatus { initial, inProgress, success, error }

class FollowStatusInfo {
  final FollowStatus status;
  final String? errorMessage;

  const FollowStatusInfo({
    this.status = FollowStatus.initial,
    this.errorMessage,
  });

  FollowStatusInfo copyWith({
    FollowStatus? status,
    String? errorMessage,
  }) {
    return FollowStatusInfo(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LikeStatusInfo {
  final LikeStatus status;
  final String? errorMessage;

  const LikeStatusInfo({
    this.status = LikeStatus.initial,
    this.errorMessage,
  });

  LikeStatusInfo copyWith({
    LikeStatus? status,
    String? errorMessage,
  }) {
    return LikeStatusInfo(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ViewStatusInfo {
  final ViewStatus status;
  final String? errorMessage;

  const ViewStatusInfo({
    this.status = ViewStatus.initial,
    this.errorMessage,
  });

  ViewStatusInfo copyWith({
    ViewStatus? status,
    String? errorMessage,
  }) {
    return ViewStatusInfo(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum ViewStatus { initial, inProgress, success, error }

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

class SyncFollowStatusesEvent extends GlobalEvent {
  final Map<String, bool> userFollowStatuses;
  final Map<String, int> userFollowersCount; // Add this
  final Map<String, int> userFollowingCount; // Add this
  final Map<String, bool> publicationViewedStatus;

  const SyncFollowStatusesEvent({
    required this.userFollowStatuses,
    required this.userFollowersCount, // Add this
    required this.userFollowingCount,
    required this.publicationViewedStatus, // Add this
  });
}

class SyncLikeStatusesEvent extends GlobalEvent {
  final Map<String, bool> publicationLikeStatuses;

  const SyncLikeStatusesEvent({
    required this.publicationLikeStatuses,
  });

  @override
  List<Object> get props => [publicationLikeStatuses];
}

class UpdateFollowStatusEvent extends GlobalEvent {
  final String userId;
  final bool isFollowed;
  final BuildContext context;

  const UpdateFollowStatusEvent({
    required this.userId,
    required this.isFollowed,
    required this.context,
  });

  @override
  List<Object> get props => [userId, isFollowed];
}

class UpdateLikeStatusEvent extends GlobalEvent {
  final String publicationId;
  final bool isLiked;
  final BuildContext context;

  const UpdateLikeStatusEvent({
    required this.publicationId,
    required this.isLiked,
    required this.context,
  });

  @override
  List<Object> get props => [publicationId, isLiked];
}

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  final FollowUserUseCase followUserUseCase;
  final LikePublicationUsecase likePublicationUsecase;
  final ViewPublicationUsecase viewPublicationUsecase;

  GlobalBloc({
    required this.followUserUseCase,
    required this.likePublicationUsecase,
    required this.viewPublicationUsecase,
  }) : super(const GlobalState()) {
    on<UpdateFollowStatusEvent>(_onUpdateFollowStatus);
    on<SyncFollowStatusesEvent>(_onSyncFollowStatuses);
    on<UpdateLikeStatusEvent>(_onUpdateLikeStatus);
    on<SyncLikeStatusesEvent>(_onSyncLikeStatuses);
    on<UpdateViewStatusEvent>(_onUpdateViewStatus);
  }



  Future<void> _onUpdateViewStatus(
    UpdateViewStatusEvent event,
    Emitter<GlobalState> emit,
  ) async {
    // Update status to inProgress
    final updatedStatusMap =
        Map<String, ViewStatusInfo>.from(state.viewStatusMap)
          ..[event.publicationId] =
              ViewStatusInfo(status: ViewStatus.inProgress);

    emit(state.copyWith(viewStatusMap: updatedStatusMap));

    final params = ViewParams(
      publicationId: event.publicationId,
    );

    final result = await viewPublicationUsecase(params: params);

    result.fold(
      (failure) {
        final newStatusMap =
            Map<String, ViewStatusInfo>.from(state.viewStatusMap)
              ..[event.publicationId] = ViewStatusInfo(
                status: ViewStatus.error,
                errorMessage: _mapFailureToMessage(failure),
              );
        emit(state.copyWith(
          viewStatusMap: newStatusMap,
        ));

        if (event.context.mounted) {}
      },
      (_) {
        final updatedViewedIds = Set<String>.from(state.viewedPublicationsIds);
        updatedViewedIds.add(event.publicationId);

        final newStatusMap =
            Map<String, ViewStatusInfo>.from(state.viewStatusMap)
              ..[event.publicationId] =
                  ViewStatusInfo(status: ViewStatus.success);

        emit(state.copyWith(
          viewedPublicationIds: updatedViewedIds,
          viewStatusMap: newStatusMap,
        ));
      },
    );
  }

  void _onSyncFollowStatuses(
    SyncFollowStatusesEvent event,
    Emitter<GlobalState> emit,
  ) {
    final updatedFollowedIds = Set<String>.from(state.followedUserIds);
    final updatedStatusMap =
        Map<String, FollowStatusInfo>.from(state.followStatusMap);
    final updatedFollowersCount =
        Map<String, int>.from(state.userFollowersCount);
    final updatedFollowingCount =
        Map<String, int>.from(state.userFollowingCount);

    final updatedViewedPublicationIds =
        Set<String>.from(state.viewedPublicationsIds);
    final updatedViewStatusMap =
        Map<String, ViewStatusInfo>.from(state.viewStatusMap);

    event.userFollowStatuses.forEach((userId, isFollowed) {
      if (isFollowed) {
        updatedFollowedIds.add(userId);
      } else {
        updatedFollowedIds.remove(userId);
      }

      final existingStatus = state.followStatusMap[userId];
      if (existingStatus == null ||
          existingStatus.status != FollowStatus.inProgress) {
        updatedStatusMap[userId] = FollowStatusInfo(
          status: FollowStatus.success,
          errorMessage: existingStatus?.errorMessage,
        );
      }

      if (event.userFollowersCount.containsKey(userId)) {
        updatedFollowersCount[userId] = event.userFollowersCount[userId]!;
      }

      if (event.userFollowingCount.containsKey(userId)) {
        updatedFollowingCount[userId] = event.userFollowingCount[userId]!;
      }
    });
    event.publicationViewedStatus.forEach((publicationId, isViewed) {
      if (isViewed) {
        updatedViewedPublicationIds.add(publicationId);
      } else {
        updatedViewedPublicationIds.remove(publicationId);
      }

      final existingStatus = state.viewStatusMap[publicationId];
      if (existingStatus == null ||
          existingStatus.status != ViewStatus.inProgress) {
        updatedViewStatusMap[publicationId] = ViewStatusInfo(
          status: ViewStatus.success,
          errorMessage: existingStatus?.errorMessage,
        );
      }
    });
    emit(state.copyWith(
      followedUserIds: updatedFollowedIds,
      followStatusMap: updatedStatusMap,
      userFollowersCount: updatedFollowersCount,
      userFollowingCount: updatedFollowingCount,
      viewedPublicationIds: updatedViewedPublicationIds,
      viewStatusMap: updatedViewStatusMap,
    ));
  }

  Future<void> _onUpdateFollowStatus(
    UpdateFollowStatusEvent event,
    Emitter<GlobalState> emit,
  ) async {
    // Update status to inProgress
    final updatedStatusMap =
        Map<String, FollowStatusInfo>.from(state.followStatusMap)
          ..[event.userId] = FollowStatusInfo(status: FollowStatus.inProgress);

    emit(state.copyWith(followStatusMap: updatedStatusMap));

    final params = FollowParams(
      userId: event.userId,
      isFollowing: !event.isFollowed,
    );

    final result = await followUserUseCase(params: params);

    result.fold(
      (failure) {
        final newStatusMap =
            Map<String, FollowStatusInfo>.from(state.followStatusMap)
              ..[event.userId] = FollowStatusInfo(
                status: FollowStatus.error,
                errorMessage: _mapFailureToMessage(failure),
              );

        emit(state.copyWith(followStatusMap: newStatusMap));

        if (event.context.mounted) {}
      },
      (userProfile) {
        // Update followed status
        final updatedFollowedIds = Set<String>.from(state.followedUserIds);
        if (userProfile.isFollowing ?? false) {
          updatedFollowedIds.add(event.userId);
        } else {
          updatedFollowedIds.remove(event.userId);
        }

        // Update followers/following counts
        final updatedFollowersCount =
            Map<String, int>.from(state.userFollowersCount)
              ..[event.userId] = userProfile.followers ?? 0;

        final updatedFollowingCount =
            Map<String, int>.from(state.userFollowingCount)
              ..[event.userId] = userProfile.following ?? 0;

        final newStatusMap =
            Map<String, FollowStatusInfo>.from(state.followStatusMap)
              ..[event.userId] = FollowStatusInfo(status: FollowStatus.success);
        if (event.context.mounted) {
          BlocProvider.of<UserProfileBloc>(event.context).add(GetUserData());
        }
        emit(state.copyWith(
          followedUserIds: updatedFollowedIds,
          followStatusMap: newStatusMap,
          userFollowersCount: updatedFollowersCount,
          userFollowingCount: updatedFollowingCount,
        ));
      },
    );
  }

  void _onSyncLikeStatuses(
    SyncLikeStatusesEvent event,
    Emitter<GlobalState> emit,
  ) {
    final updatedLikedIds = Set<String>.from(state.likedPublicationIds);
    final updatedStatusMap =
        Map<String, LikeStatusInfo>.from(state.likeStatusMap);

    event.publicationLikeStatuses.forEach((publicationId, isLiked) {
      if (isLiked) {
        updatedLikedIds.add(publicationId);
      } else {
        updatedLikedIds.remove(publicationId);
      }

      final existingStatus = state.likeStatusMap[publicationId];

      if (existingStatus == null ||
          existingStatus.status != LikeStatus.inProgress) {
        updatedStatusMap[publicationId] = LikeStatusInfo(
          status: LikeStatus.success,
          errorMessage: existingStatus?.errorMessage,
        );
        print('Updated status to success for $publicationId');
      }
    });

    emit(state.copyWith(
      likedPublicationIds: updatedLikedIds,
      likeStatusMap: updatedStatusMap,
    ));
  }

  Future<void> _onUpdateLikeStatus(
    UpdateLikeStatusEvent event,
    Emitter<GlobalState> emit,
  ) async {
    // Update status to inProgress
    final updatedStatusMap =
        Map<String, LikeStatusInfo>.from(state.likeStatusMap)
          ..[event.publicationId] =
              LikeStatusInfo(status: LikeStatus.inProgress);

    emit(state.copyWith(likeStatusMap: updatedStatusMap));

    final params = LikeParams(
      publicationId: event.publicationId,
      isLiked: !event.isLiked, // Toggle the current status
    );

    final result = await likePublicationUsecase(params: params);

    result.fold(
      (failure) {
        final newStatusMap =
            Map<String, LikeStatusInfo>.from(state.likeStatusMap)
              ..[event.publicationId] = LikeStatusInfo(
                status: LikeStatus.error,
                errorMessage: _mapFailureToMessage(failure),
              );
        emit(state.copyWith(likeStatusMap: newStatusMap));

        if (event.context.mounted) {}
      },
      (_) {
        final updatedLikedIds = Set<String>.from(state.likedPublicationIds);
        if (!event.isLiked) {
          updatedLikedIds.add(event.publicationId);
        } else {
          updatedLikedIds.remove(event.publicationId);
        }

        final newStatusMap =
            Map<String, LikeStatusInfo>.from(state.likeStatusMap)
              ..[event.publicationId] =
                  LikeStatusInfo(status: LikeStatus.success);

        emit(state.copyWith(
          likedPublicationIds: updatedLikedIds,
          likeStatusMap: newStatusMap,
        ));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server error occurred';
      case NetworkFailure _:
        return 'Network error occurred';
      case ValidationFailure _:
        return 'Validation error occurred';
      default:
        return 'Unexpected error occurred';
    }
  }
}

abstract class GlobalEvent extends Equatable {
  const GlobalEvent();

  @override
  List<Object> get props => [];
}

class UpdateViewStatusEvent extends GlobalEvent {
  final String publicationId;
  final bool isViewed;
  final BuildContext context;

  const UpdateViewStatusEvent({
    required this.publicationId,
    required this.isViewed,
    required this.context,
  });

  @override
  List<Object> get props => [publicationId, isViewed];
}
