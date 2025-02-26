// global_bloc.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/auth/data/sources/auth_local_data_source.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_event.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/follow_usecase.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/like_publication_usecase.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/view_publication_usecase.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  final FollowUserUseCase followUserUseCase;
  final LikePublicationUsecase likePublicationUsecase;
  final ViewPublicationUsecase viewPublicationUsecase;
  final AuthLocalDataSource authLocalDataSource;
  String? userId;
  String? profileImagePath;
  GlobalBloc({
    required this.followUserUseCase,
    required this.likePublicationUsecase,
    required this.viewPublicationUsecase,
    required this.authLocalDataSource,
  }) : super(const GlobalState()) {
    on<UpdateFollowStatusEvent>(_onUpdateFollowStatus);
    on<SyncFollowStatusesEvent>(_onSyncFollowStatuses);
    on<UpdateLikeStatusEvent>(_onUpdateLikeStatus);
    on<SyncLikeStatusesEvent>(_onSyncLikeStatuses);
    on<UpdateViewStatusEvent>(_onUpdateViewStatus);
    on<FetchUserIdEvent>(_onFetchUserId);
    on<FetchUserImageEvent>(_onFetchUserImage);
    add(FetchUserIdEvent());
    add(FetchUserImageEvent());
  }

  Future<void> _onFetchUserId(
      FetchUserIdEvent event, Emitter<GlobalState> emit) async {
    userId = AppSession.currentUserId;

    if (userId == null) {
      userId = await authLocalDataSource.getUserId();

      if (userId != null) {
        AppSession.currentUserId = userId;
      }
    }

    debugPrint('🎯 GlobalBloc fetched userId: $userId');
  }

  Future<void> _onFetchUserImage(
      FetchUserImageEvent event, Emitter<GlobalState> emit) async {
    profileImagePath = AppSession.profileImagePath;

    if (profileImagePath == null) {
      profileImagePath = await authLocalDataSource.getProfileImagePath();

      if (profileImagePath != null) {
        AppSession.profileImagePath = profileImagePath;
      }
    }

    debugPrint('🎯 GlobalBloc fetched userId: $userId');
  }

  String? getUserId() {
    return userId;
  }

  String? getUserProfileImage() {
    return profileImagePath;
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
