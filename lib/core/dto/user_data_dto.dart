import 'package:list_in/features/auth/data/models/auth_token_model.dart';
import 'package:list_in/features/auth/domain/entities/auth_tokens.dart';
import 'package:list_in/features/profile/data/model/user/user_data_model.dart';
import 'package:list_in/features/profile/domain/entity/user/user_data_entity.dart';

class UserDataDtoModel {
  final UserDataModel user;
  final AuthTokenModel tokens;

  UserDataDtoModel({
    required this.user,
    required this.tokens,
  });

  factory UserDataDtoModel.fromJson(Map<String, dynamic> json) {
    // Handle the nested time objects by converting them to strings
    Map<String, dynamic> userResponseDto =
        Map<String, dynamic>.from(json['userResponseDTO']);

    return UserDataDtoModel(
      user: UserDataModel.fromJson(userResponseDto),
      tokens: AuthTokenModel.fromJson({
        'access_token': json['access_token'],
        'refresh_token': json['refresh_token'],
      }),
    );
  }

  UserDataDtoEntity toEntity() {
    return UserDataDtoEntity(
      user: user.toEntity(),
      tokens: tokens.toEntity(),
    );
  }
}

class UserDataDtoEntity {
  final UserDataEntity user;
  final AuthToken tokens;

  UserDataDtoEntity({
    required this.user,
    required this.tokens,
  });
}
