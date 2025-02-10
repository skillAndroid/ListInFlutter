import 'package:list_in/features/profile/domain/entity/another_user/another_user_profile_entity.dart';

enum AnotherUserProfileStatus { initial, loading, success, failure }

class AnotherUserProfileState {
  final AnotherUserProfileStatus status;
  final AnotherUserProfileEntity? profile;
  final String? errorMessage;

  AnotherUserProfileState({
    this.status = AnotherUserProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  AnotherUserProfileState copyWith({
    AnotherUserProfileStatus? status,
    AnotherUserProfileEntity? profile,
    String? errorMessage,
  }) {
    return AnotherUserProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
