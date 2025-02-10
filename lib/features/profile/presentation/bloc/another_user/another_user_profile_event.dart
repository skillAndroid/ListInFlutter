abstract class AnotherUserProfileEvent {}

class GetAnotherUserData extends AnotherUserProfileEvent {
  final String userId;
  GetAnotherUserData(this.userId);
}