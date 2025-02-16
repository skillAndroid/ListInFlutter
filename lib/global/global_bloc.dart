// global_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/follow_usecase.dart';

enum FollowStatus { initial, inProgress, success, error }

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

class GlobalState extends Equatable {
  final Map<String, FollowStatusInfo> followStatusMap;
  final Set<String> followedUserIds;

  const GlobalState({
    this.followStatusMap = const {},
    this.followedUserIds = const {},
  });

  bool isUserFollowed(String userId) => followedUserIds.contains(userId);

  FollowStatus getFollowStatus(String userId) =>
      followStatusMap[userId]?.status ?? FollowStatus.initial;

  GlobalState copyWith({
    Map<String, FollowStatusInfo>? followStatusMap,
    Set<String>? followedUserIds,
  }) {
    return GlobalState(
      followStatusMap: followStatusMap ?? this.followStatusMap,
      followedUserIds: followedUserIds ?? this.followedUserIds,
    );
  }

  @override
  List<Object> get props => [followStatusMap, followedUserIds];
}

abstract class GlobalEvent extends Equatable {
  const GlobalEvent();

  @override
  List<Object> get props => [];
}

class SyncFollowStatusesEvent extends GlobalEvent {
  final Map<String, bool> userFollowStatuses;

  const SyncFollowStatusesEvent({
    required this.userFollowStatuses,
  });

  @override
  List<Object> get props => [userFollowStatuses];
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

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  final FollowUserUseCase followUserUseCase;

  GlobalBloc({
    required this.followUserUseCase,
  }) : super(const GlobalState()) {
    on<UpdateFollowStatusEvent>(_onUpdateFollowStatus);
    on<SyncFollowStatusesEvent>(_onSyncFollowStatuses);
  }

  void _onSyncFollowStatuses(
    SyncFollowStatusesEvent event,
    Emitter<GlobalState> emit,
  ) {
    final updatedFollowedIds = Set<String>.from(state.followedUserIds);
    final updatedStatusMap =
        Map<String, FollowStatusInfo>.from(state.followStatusMap);

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
    });

    emit(state.copyWith(
      followedUserIds: updatedFollowedIds,
      followStatusMap: updatedStatusMap,
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
      isFollowing: !event.isFollowed, // Toggle the current status
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

        // Show error message using SnackBar
        if (event.context.mounted) {}
      },
      (_) {
        final updatedFollowedIds = Set<String>.from(state.followedUserIds);
        if (!event.isFollowed) {
          updatedFollowedIds.add(event.userId);
        } else {
          updatedFollowedIds.remove(event.userId);
        }

        final newStatusMap =
            Map<String, FollowStatusInfo>.from(state.followStatusMap)
              ..[event.userId] = FollowStatusInfo(status: FollowStatus.success);

        emit(state.copyWith(
          followedUserIds: updatedFollowedIds,
          followStatusMap: newStatusMap,
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
