import 'package:flutter/cupertino.dart';

abstract class AnotherUserProfileEvent {}

class GetAnotherUserData extends AnotherUserProfileEvent {
  final String userId;
  GetAnotherUserData(this.userId);
}

class FetchPublications extends AnotherUserProfileEvent {
  final String userId;
  final bool isInitialFetch;

  FetchPublications({
    required this.userId,
    this.isInitialFetch = false,
  });
}

class FollowUser extends AnotherUserProfileEvent {
  final String userId;
  final bool isFollowing;
  final BuildContext context;

  FollowUser({
    required this.userId,
    required this.isFollowing,
    required this.context,
  });
}

class ClearUserData extends AnotherUserProfileEvent {} // Новый ивент
