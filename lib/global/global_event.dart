// global_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class GlobalEvent extends Equatable {
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
