// social_user_bloc.dart

// ignore_for_file: avoid_print

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/features/followers/domain/entity/user_followings_followers_data.dart';
import 'package:list_in/features/followers/domain/usecase/get_user_followers_usecase.dart';
import 'package:list_in/features/followers/domain/usecase/get_user_followings_usecase.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';

// Events
abstract class SocialUserEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchFollowers extends SocialUserEvent {
  final String userId;
  final bool refresh;
  final int page;
  final Function(List<UserProfile>, bool)? onSuccess;
  final Function(Object)? onError;

  FetchFollowers({
    required this.userId,
    this.refresh = false,
    this.page = 0,
    this.onSuccess,
    this.onError,
  });

  @override
  List<Object> get props => [userId, refresh, page];
}

class FetchFollowings extends SocialUserEvent {
  final String userId;
  final bool refresh;
  final int page;
  final Function(List<UserProfile>, bool)? onSuccess;
  final Function(Object)? onError;

  FetchFollowings({
    required this.userId,
    this.refresh = false,
    this.page = 0,
    this.onSuccess,
    this.onError,
  });

  @override
  List<Object> get props => [userId, refresh, page];
}

class FollowUser extends SocialUserEvent {
  final String userId;
  final bool isFollowing;
  final BuildContext? context;

  FollowUser({
    required this.userId,
    required this.isFollowing,
    this.context,
  });

  @override
  List<Object> get props => [userId, isFollowing];
}

// States
abstract class SocialUserState extends Equatable {
  @override
  List<Object> get props => [];
}

class SocialUserInitial extends SocialUserState {}

class SocialUserLoading extends SocialUserState {}

class FollowersLoaded extends SocialUserState {
  final List<UserProfile> followers;
  final bool hasReachedMax;
  final int currentPage;

  FollowersLoaded({
    required this.followers,
    required this.hasReachedMax,
    required this.currentPage,
  });

  FollowersLoaded copyWith({
    List<UserProfile>? followers,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return FollowersLoaded(
      followers: followers ?? this.followers,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [followers, hasReachedMax, currentPage];
}

class FollowingsLoaded extends SocialUserState {
  final List<UserProfile> followings;
  final bool hasReachedMax;
  final int currentPage;

  FollowingsLoaded({
    required this.followings,
    required this.hasReachedMax,
    required this.currentPage,
  });

  FollowingsLoaded copyWith({
    List<UserProfile>? followings,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return FollowingsLoaded(
      followings: followings ?? this.followings,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [followings, hasReachedMax, currentPage];
}

class SocialUserError extends SocialUserState {
  final String message;

  SocialUserError(this.message);

  @override
  List<Object> get props => [message];
}

class FollowActionSuccess extends SocialUserState {
  final String userId;
  final bool isFollowing;

  FollowActionSuccess({required this.userId, required this.isFollowing});

  @override
  List<Object> get props => [userId, isFollowing];
}

// BLoC
class SocialUserBloc extends Bloc<SocialUserEvent, SocialUserState> {
  final GetUserFollowersUseCase getUserFollowersUseCase;
  final GetUserFollowingsUseCase getUserFollowingsUseCase;
  final GlobalBloc globalBloc;

  static const int pageSize = 30;

  SocialUserBloc({
    required this.getUserFollowersUseCase,
    required this.getUserFollowingsUseCase,
    required this.globalBloc,
  }) : super(SocialUserInitial()) {
    on<FetchFollowers>(_onFetchFollowers);
    on<FetchFollowings>(_onFetchFollowings);
    on<FollowUser>(_onFollowUser);
  }

  void _syncFollowStatusesForPublications(List<UserProfile> profiles) {
    final Map<String, bool> userFollowStatuses = {};
    final Map<String, int> userFollowersCount = {};
    final Map<String, int> userFollowingCount = {};
    final Map<String, bool> publicationViewedStatus = {};

    for (var profile in profiles) {
      userFollowStatuses[profile.userId] = profile.isFollowing;
      userFollowersCount[profile.userId] = profile.followers;
      userFollowingCount[profile.userId] = profile.following;
    }

    globalBloc.add(SyncFollowStatusesEvent(
      userFollowStatuses: userFollowStatuses,
      userFollowersCount: userFollowersCount,
      userFollowingCount: userFollowingCount,
      publicationViewedStatus: publicationViewedStatus,
    ));
  }

  Future<void> _onFetchFollowers(
    FetchFollowers event,
    Emitter<SocialUserState> emit,
  ) async {
    try {
      // If this is a refresh request, start from page 0
      if (event.refresh) {
        emit(SocialUserLoading());
      }

      print(
          '📱 Fetching followers for user: ${event.userId}, page: ${event.page}');

      final result = await getUserFollowersUseCase(
        params: UserSocialParams(
          userId: event.userId,
          page: event.page,
          size: pageSize,
        ),
      );

      return result.fold(
        (failure) {
          print('❌ Failed to fetch followers: $failure');
          final errorMessage = 'Failed to load followers';

          if (event.onError != null) {
            event.onError!(errorMessage);
          }

          emit(SocialUserError(errorMessage));
        },
        (data) {
          _syncFollowStatusesForPublications(data.content);

          print(
              '✅ Loaded ${data.content.length} followers. Last page: ${data.last}');

          // Call the onSuccess callback with the results
          if (event.onSuccess != null) {
            event.onSuccess!(data.content, data.last);
          }

          // Still emit state for widgets using BLoC directly
          if (event.page == 0) {
            emit(
              FollowersLoaded(
                followers: data.content,
                hasReachedMax: data.last,
                currentPage: 0,
              ),
            );
          } else if (state is FollowersLoaded) {
            final currentState = state as FollowersLoaded;

            emit(
              FollowersLoaded(
                followers: [...currentState.followers, ...data.content],
                hasReachedMax: data.last,
                currentPage: event.page,
              ),
            );
          }
        },
      );
    } catch (e) {
      print('❌ Error fetching followers: $e');
      final errorMessage = 'An unexpected error occurred';

      if (event.onError != null) {
        event.onError!(errorMessage);
      }

      emit(SocialUserError(errorMessage));
    }
  }

  Future<void> _onFetchFollowings(
    FetchFollowings event,
    Emitter<SocialUserState> emit,
  ) async {
    try {
      // If this is a refresh request, start from page 0
      if (event.refresh) {
        emit(SocialUserLoading());
      }

      print(
          '📱 Fetching followings for user: ${event.userId}, page: ${event.page}');

      final result = await getUserFollowingsUseCase(
        params: UserSocialParams(
          userId: event.userId,
          page: event.page,
          size: pageSize,
        ),
      );

      return result.fold(
        (failure) {
          print('❌ Failed to fetch followings: $failure');
          final errorMessage = 'Failed to load followings';

          if (event.onError != null) {
            event.onError!(errorMessage);
          }

          emit(SocialUserError(errorMessage));
        },
        (data) {
          _syncFollowStatusesForPublications(data.content);

          print(
              '✅ Loaded ${data.content.length} followings. Last page: ${data.last}');

          // Call the onSuccess callback with the results
          if (event.onSuccess != null) {
            event.onSuccess!(data.content, data.last);
          }

          // Still emit state for widgets using BLoC directly
          if (event.page == 0) {
            emit(
              FollowingsLoaded(
                followings: data.content,
                hasReachedMax: data.last,
                currentPage: 0,
              ),
            );
          } else if (state is FollowingsLoaded) {
            final currentState = state as FollowingsLoaded;

            emit(
              FollowingsLoaded(
                followings: [...currentState.followings, ...data.content],
                hasReachedMax: data.last,
                currentPage: event.page,
              ),
            );
          }
        },
      );
    } catch (e) {
      print('❌ Error fetching followings: $e');
      final errorMessage = 'An unexpected error occurred';

      if (event.onError != null) {
        event.onError!(errorMessage);
      }

      emit(SocialUserError(errorMessage));
    }
  }

  Future<void> _onFollowUser(
    FollowUser event,
    Emitter<SocialUserState> emit,
  ) async {
    try {
      print(
          '🔄 Toggling follow status for user: ${event.userId}, current status: ${event.isFollowing}');

      // We need to store the context in the event
      // and pass it to the global bloc event
      globalBloc.add(
        UpdateFollowStatusEvent(
          userId: event.userId,
          isFollowed: event.isFollowing,
          context: event.context!, // Pass the context from the event
        ),
      );

      // Emit a success state
      emit(FollowActionSuccess(
        userId: event.userId,
        isFollowing: !event.isFollowing,
      ));

      // Restore the previous state to maintain the list view
      if (state is FollowActionSuccess) {
        final previousState = state;
        if (previousState is FollowersLoaded) {
          emit(previousState);
        } else if (previousState is FollowingsLoaded) {
          emit(previousState);
        }
      }
    } catch (e) {
      print('❌ Error toggling follow status: $e');
      emit(SocialUserError('Failed to update follow status'));
    }
  }
}
