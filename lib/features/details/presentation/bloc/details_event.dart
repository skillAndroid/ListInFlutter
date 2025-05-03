import 'package:flutter/cupertino.dart';

abstract class DetailsEvent {}

class GetAnotherUserData extends DetailsEvent {
  final String userId;
  GetAnotherUserData(this.userId);
}

class FetchPublications extends DetailsEvent {
  final String userId;
  final bool isInitialFetch;

  FetchPublications({
    required this.userId,
    this.isInitialFetch = false,
  });
}

class FollowUser extends DetailsEvent {
  final String userId;
  final bool isFollowing;
  final BuildContext context;

  FollowUser({
    required this.userId,
    required this.isFollowing,
    required this.context,
  });
}

// New event for fetching single publication
class FetchSinglePublication extends DetailsEvent {
  final String publicationId;
  FetchSinglePublication({required this.publicationId});
}
