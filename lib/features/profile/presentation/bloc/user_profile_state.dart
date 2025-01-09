import 'package:list_in/features/profile/domain/entity/user_data_entity.dart';
import 'package:list_in/features/profile/domain/entity/user_profile_entity.dart';

enum UserProfileStatus { initial, loading, success, failure }
class UserProfileState {
  final UserProfileStatus status;
  final UserProfileEntity? profile;
  final UserDataEntity? userData;
  final String? errorMessage;
  final bool isUploading;

  UserProfileState({
    this.status = UserProfileStatus.initial,
    this.profile,
    this.userData,
    this.errorMessage,
    this.isUploading = false,
  });

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserProfileEntity? profile,
    UserDataEntity? userData,
    String? errorMessage,
    bool? isUploading,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      userData: userData ?? this.userData,
      errorMessage: errorMessage ?? this.errorMessage,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}