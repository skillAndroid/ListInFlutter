import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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


class FetchUserIdEvent extends GlobalEvent {}


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
