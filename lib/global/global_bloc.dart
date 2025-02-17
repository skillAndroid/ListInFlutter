// global_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/follow_usecase.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/like_publication_usecase.dart';

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

class GlobalState extends Equatable {
  final Map<String, FollowStatusInfo> followStatusMap;
  final Set<String> followedUserIds;
  final Map<String, LikeStatusInfo> likeStatusMap;
  final Set<String> likedPublicationIds;

  const GlobalState({
    this.followStatusMap = const {},
    this.followedUserIds = const {},
    this.likeStatusMap = const {},
    this.likedPublicationIds = const {},
  });

  bool isUserFollowed(String userId) => followedUserIds.contains(userId);

  FollowStatus getFollowStatus(String userId) =>
      followStatusMap[userId]?.status ?? FollowStatus.initial;

  bool isPublicationLiked(String publicationId) =>
      likedPublicationIds.contains(publicationId);

  LikeStatus getLikeStatus(String publicationId) =>
      likeStatusMap[publicationId]?.status ?? LikeStatus.initial;

  GlobalState copyWith({
    Map<String, FollowStatusInfo>? followStatusMap,
    Set<String>? followedUserIds,
    Map<String, LikeStatusInfo>? likeStatusMap,
    Set<String>? likedPublicationIds,
  }) {
    return GlobalState(
      followStatusMap: followStatusMap ?? this.followStatusMap,
      followedUserIds: followedUserIds ?? this.followedUserIds,
      likeStatusMap: likeStatusMap ?? this.likeStatusMap,
      likedPublicationIds: likedPublicationIds ?? this.likedPublicationIds,
    );
  }

  @override
  List<Object> get props => [
        followStatusMap,
        followedUserIds,
        likeStatusMap,
        likedPublicationIds,
      ];
}

class SyncFollowStatusesEvent extends GlobalEvent {
  final Map<String, bool> userFollowStatuses;

  const SyncFollowStatusesEvent({
    required this.userFollowStatuses,
  });

  @override
  List<Object> get props => [userFollowStatuses];
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

  GlobalBloc({
    required this.followUserUseCase,
    required this.likePublicationUsecase,
  }) : super(const GlobalState()) {
    on<UpdateFollowStatusEvent>(_onUpdateFollowStatus);
    on<SyncFollowStatusesEvent>(_onSyncFollowStatuses);
    on<UpdateLikeStatusEvent>(_onUpdateLikeStatus);
    on<SyncLikeStatusesEvent>(_onSyncLikeStatuses);
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

 void _onSyncLikeStatuses(
    SyncLikeStatusesEvent event,
    Emitter<GlobalState> emit,
  ) {
    print('🔄 Starting _onSyncLikeStatuses');
    print('Current state: ${state.likedPublicationIds.length} liked IDs');
    print('Incoming updates: ${event.publicationLikeStatuses.length} items');
    
    final updatedLikedIds = Set<String>.from(state.likedPublicationIds);
    final updatedStatusMap = Map<String, LikeStatusInfo>.from(state.likeStatusMap);
    
    event.publicationLikeStatuses.forEach((publicationId, isLiked) {
      print('Processing publication $publicationId - isLiked: $isLiked');
      
      if (isLiked) {
        updatedLikedIds.add(publicationId);
      } else {
        updatedLikedIds.remove(publicationId);
      }
      
      final existingStatus = state.likeStatusMap[publicationId];
      print('Existing status for $publicationId: ${existingStatus?.status}');
      
      if (existingStatus == null ||
          existingStatus.status != LikeStatus.inProgress) {
        updatedStatusMap[publicationId] = LikeStatusInfo(
          status: LikeStatus.success,
          errorMessage: existingStatus?.errorMessage,
        );
        print('Updated status to success for $publicationId');
      }
    });
    
    print('Final state: ${updatedLikedIds.length} liked IDs');
    emit(state.copyWith(
      likedPublicationIds: updatedLikedIds,
      likeStatusMap: updatedStatusMap,
    ));
  }

  Future<void> _onUpdateLikeStatus(
    UpdateLikeStatusEvent event,
    Emitter<GlobalState> emit,
  ) async {
    print('👍 Starting _onUpdateLikeStatus');
    print('Publication ID: ${event.publicationId}');
    print('Current isLiked: ${event.isLiked}');
    
    // Update status to inProgress
    final updatedStatusMap =
        Map<String, LikeStatusInfo>.from(state.likeStatusMap)
          ..[event.publicationId] =
              LikeStatusInfo(status: LikeStatus.inProgress);
    
    print('Setting status to inProgress');
    emit(state.copyWith(likeStatusMap: updatedStatusMap));
    
    final params = LikeParams(
      publicationId: event.publicationId,
      isLiked: !event.isLiked, // Toggle the current status
    );
    
    print('Calling likePublicationUsecase with isLiked: ${params.isLiked}');
    final result = await likePublicationUsecase(params: params);
    
    result.fold(
      (failure) {
        print('❌ Error occurred: ${_mapFailureToMessage(failure)}');
        final newStatusMap =
            Map<String, LikeStatusInfo>.from(state.likeStatusMap)
              ..[event.publicationId] = LikeStatusInfo(
                status: LikeStatus.error,
                errorMessage: _mapFailureToMessage(failure),
              );
        emit(state.copyWith(likeStatusMap: newStatusMap));
        
        if (event.context.mounted) {
          print('Context is mounted, can show error UI');
          // Add your error handling UI logic here
        }
      },
      (_) {
        print('✅ Success updating like status');
        final updatedLikedIds = Set<String>.from(state.likedPublicationIds);
        if (!event.isLiked) {
          updatedLikedIds.add(event.publicationId);
          print('Added ${event.publicationId} to liked IDs');
        } else {
          updatedLikedIds.remove(event.publicationId);
          print('Removed ${event.publicationId} from liked IDs');
        }
        
        final newStatusMap =
            Map<String, LikeStatusInfo>.from(state.likeStatusMap)
              ..[event.publicationId] =
                  LikeStatusInfo(status: LikeStatus.success);
        
        print('Final liked IDs count: ${updatedLikedIds.length}');
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
