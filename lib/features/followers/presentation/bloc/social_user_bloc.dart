// social_user_bloc.dart

import 'package:equatable/equatable.dart';
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

  FetchFollowers({required this.userId, this.refresh = false});

  @override
  List<Object> get props => [userId, refresh];
}

class FetchFollowings extends SocialUserEvent {
  final String userId;
  final bool refresh;

  FetchFollowings({required this.userId, this.refresh = false});

  @override
  List<Object> get props => [userId, refresh];
}

class FollowUser extends SocialUserEvent {
  final String userId;
  final bool isFollowing;

  FollowUser({
    required this.userId,
    required this.isFollowing,
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
      // If this is the first fetch or a refresh, emit loading state
      if (state is! FollowersLoaded || event.refresh) {
        emit(SocialUserLoading());
        final result = await getUserFollowersUseCase(
          params: UserSocialParams(
            userId: event.userId,
            page: 0,
            size: pageSize,
          ),
        );

        return result.fold(
            (failure) => emit(SocialUserError('Failed to load followers')),
            (data) {
          _syncFollowStatusesForPublications(data.content);
          emit(
            FollowersLoaded(
              followers: data.content,
              hasReachedMax: data.last,
              currentPage: 0,
            ),
          );
        });
      }

      // Handle pagination (loading more data)
      final currentState = state as FollowersLoaded;

      // If we've reached max, don't fetch more
      if (currentState.hasReachedMax) return;

      final nextPage = currentState.currentPage + 1;
      final result = await getUserFollowersUseCase(
        params: UserSocialParams(
          userId: event.userId,
          page: nextPage,
          size: pageSize,
        ),
      );

      return result.fold(
        (failure) => emit(SocialUserError('Failed to load more followers')),
        (data) {
          _syncFollowStatusesForPublications(data.content);
          if (data.content.isEmpty) {
            emit(currentState.copyWith(hasReachedMax: true));
          } else {
            emit(
              FollowersLoaded(
                followers: [...currentState.followers, ...data.content],
                hasReachedMax: data.last,
                currentPage: nextPage,
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(SocialUserError('An unexpected error occurred'));
    }
  }

  Future<void> _onFetchFollowings(
    FetchFollowings event,
    Emitter<SocialUserState> emit,
  ) async {
    try {
      // If this is the first fetch or a refresh, emit loading state
      if (state is! FollowingsLoaded || event.refresh) {
        emit(SocialUserLoading());
        final result = await getUserFollowingsUseCase(
          params: UserSocialParams(
            userId: event.userId,
            page: 0,
            size: pageSize,
          ),
        );

        return result.fold(
            (failure) => emit(SocialUserError('Failed to load followings')),
            (data) {
          _syncFollowStatusesForPublications(data.content);
          emit(
            FollowingsLoaded(
              followings: data.content,
              hasReachedMax: data.last,
              currentPage: 0,
            ),
          );
        });
      }

      // Handle pagination (loading more data)
      final currentState = state as FollowingsLoaded;

      // If we've reached max, don't fetch more
      if (currentState.hasReachedMax) return;

      final nextPage = currentState.currentPage + 1;
      final result = await getUserFollowingsUseCase(
        params: UserSocialParams(
          userId: event.userId,
          page: nextPage,
          size: pageSize,
        ),
      );

      return result.fold(
        (failure) => emit(SocialUserError('Failed to load more followings')),
        (data) {
          _syncFollowStatusesForPublications(data.content);
          if (data.content.isEmpty) {
            emit(currentState.copyWith(hasReachedMax: true));
          } else {
            emit(
              FollowingsLoaded(
                followings: [...currentState.followings, ...data.content],
                hasReachedMax: data.last,
                currentPage: nextPage,
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(SocialUserError('An unexpected error occurred'));
    }
  }
}
