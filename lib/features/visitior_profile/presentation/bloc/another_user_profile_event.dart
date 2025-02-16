

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

class ClearUserData extends AnotherUserProfileEvent {} 
