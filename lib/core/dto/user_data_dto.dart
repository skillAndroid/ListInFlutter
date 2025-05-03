import 'package:list_in/features/auth/data/models/auth_token_model.dart';
import 'package:list_in/features/profile/data/model/user/user_data_model.dart';

class UserDataDto {
  final UserDataModel user;
  final AuthTokenModel tokens;

  UserDataDto({
    required this.user,
    required this.tokens,
  });

  factory UserDataDto.fromJson(Map<String, dynamic> json) {
    // Handle the nested time objects by converting them to strings
    Map<String, dynamic> userResponseDto =
        Map<String, dynamic>.from(json['userResponseDTO']);

    // Convert fromTime object to string if it exists and is a Map
    if (userResponseDto['fromTime'] is Map<String, dynamic>) {
      var fromTimeObj = userResponseDto['fromTime'] as Map<String, dynamic>;
      userResponseDto['fromTime'] =
          '${fromTimeObj['hour'].toString().padLeft(2, '0')}:${fromTimeObj['minute'].toString().padLeft(2, '0')}';
    }

    // Convert toTime object to string if it exists and is a Map
    if (userResponseDto['toTime'] is Map<String, dynamic>) {
      var toTimeObj = userResponseDto['toTime'] as Map<String, dynamic>;
      userResponseDto['toTime'] =
          '${toTimeObj['hour'].toString().padLeft(2, '0')}:${toTimeObj['minute'].toString().padLeft(2, '0')}';
    }

    // Add 'status' field if it doesn't exist in your UserDataModel
    // Remove it if your model doesn't handle 'status'
    userResponseDto.remove('status');

    return UserDataDto(
      user: UserDataModel.fromJson(userResponseDto),
      tokens: AuthTokenModel.fromJson({
        'access_token': json['access_token'],
        'refresh_token': json['refresh_token'],
      }),
    );
  }
}
